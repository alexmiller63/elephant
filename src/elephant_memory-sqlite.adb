with Ada.Calendar;
with Ada.Characters.Handling;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;
with System.Storage_Elements;

package body Elephant_Memory.SQLite is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   use type C.int;
   use type CS.chars_ptr;
   use type System.Address;

   OK : constant C.int := 0;
   Row : constant C.int := 100;
   Done : constant C.int := 101;
   Constraint_Failure : constant C.int := 19;

   function SQLite_Open
     (Name : CS.chars_ptr; DB : access System.Address; Flags : C.int;
      VFS : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_open_v2";
   function SQLite_Close (DB : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_close_v2";
   function Error_Message (DB : System.Address) return CS.chars_ptr
     with Import, Convention => C, External_Name => "sqlite3_errmsg";
   function Exec
     (DB : System.Address; SQL : CS.chars_ptr;
      Callback, Argument, Error : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_exec";
   function Prepare_V2
     (DB : System.Address; SQL : CS.chars_ptr; Length : C.int;
      Result : access System.Address; Tail : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_prepare_v2";
   function Bind_Text
     (Stmt : System.Address; Index : C.int; Value : CS.chars_ptr;
      Length : C.int; Destructor : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_bind_text";
   function Step (Stmt : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_step";
   function Finish (Stmt : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_finalize";
   function Column_Text (Stmt : System.Address; Index : C.int) return CS.chars_ptr
     with Import, Convention => C, External_Name => "sqlite3_column_text";
   function Column_Bytes (Stmt : System.Address; Index : C.int) return C.int
     with Import, Convention => C, External_Name => "sqlite3_column_bytes";
   function Changes (DB : System.Address) return C.int
     with Import, Convention => C, External_Name => "sqlite3_changes";
   function Busy_Timeout (DB : System.Address; Milliseconds : C.int) return C.int
     with Import, Convention => C, External_Name => "sqlite3_busy_timeout";

   type Statement is new Ada.Finalization.Limited_Controlled with record
      Handle : aliased System.Address := System.Null_Address;
   end record;
   overriding procedure Finalize (Item : in out Statement);

   overriding procedure Finalize (Item : in out Statement) is
      Ignored : C.int;
   begin
      if Item.Handle /= System.Null_Address then
         Ignored := Finish (Item.Handle);
         Item.Handle := System.Null_Address;
      end if;
   end Finalize;

   overriding procedure Finalize (Item : in out Connection) is
      Ignored : C.int;
   begin
      if Item.Handle /= System.Null_Address then
         Ignored := SQLite_Close (Item.Handle);
         Item.Handle := System.Null_Address;
      end if;
   end Finalize;

   procedure Check (DB : System.Address; Status : C.int;
                    Event_Error : Boolean := False) is
   begin
      if Status /= OK then
         if Event_Error and then Status = Constraint_Failure then
            raise Invalid_Event with CS.Value (Error_Message (DB));
         end if;
         raise Storage_Error with CS.Value (Error_Message (DB));
      end if;
   end Check;

   procedure Require_Open (Target : SQLite_Store) is
   begin
      if Target.Database.Handle = System.Null_Address then
         raise Storage_Error with "store is closed";
      end if;
   end Require_Open;

   procedure Validate_Text (Value : String; Required : Boolean := True) is
   begin
      if (Required and then Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both) = "")
        or else (for some Ch of Value => Ch = Character'Val (0))
      then
         raise Invalid_Event with "empty text or embedded NUL";
      end if;
   end Validate_Text;

   procedure Execute (DB : System.Address; SQL : String) is
      Input : CS.chars_ptr := CS.New_String (SQL);
      Status : C.int;
   begin
      Status := Exec (DB, Input, System.Null_Address, System.Null_Address,
                      System.Null_Address);
      CS.Free (Input);
      Check (DB, Status);
   end Execute;

   procedure Prepare (DB : System.Address; SQL : String;
                      Result : in out Statement) is
      Input : CS.chars_ptr := CS.New_String (SQL);
      Status : C.int;
   begin
      Status := Prepare_V2 (DB, Input, -1, Result.Handle'Access, System.Null_Address);
      CS.Free (Input);
      Check (DB, Status);
   end Prepare;

   procedure Bind (DB : System.Address; Stmt : Statement;
                   Index : C.int; Value : String) is
      Input : CS.chars_ptr := CS.New_String (Value);
      Status : C.int;
      --  SQLITE_TRANSIENT: SQLite copies the bytes before Bind_Text returns.
      Transient : constant System.Address := System.Storage_Elements.To_Address
        (System.Storage_Elements.Integer_Address'Last);
   begin
      Status := Bind_Text (Stmt.Handle, Index, Input, C.int (Value'Length), Transient);
      CS.Free (Input);
      Check (DB, Status);
   end Bind;

   function Column (Stmt : Statement; Index : C.int) return Text is
      Pointer : constant CS.chars_ptr := Column_Text (Stmt.Handle, Index);
      Length : constant C.int := Column_Bytes (Stmt.Handle, Index);
   begin
      if Pointer = CS.Null_Ptr then
         return Null_Unbounded_String;
      end if;
      return To_Unbounded_String (CS.Value (Pointer, C.size_t (Length)));
   end Column;

   function Scalar (DB : System.Address; SQL : String) return Natural is
      Stmt : Statement;
      Status : C.int;
   begin
      Prepare (DB, SQL, Stmt);
      Status := Step (Stmt.Handle);
      if Status /= Row then
         Check (DB, Status);
         raise Storage_Error with "expected a scalar result";
      end if;
      return Natural'Value (To_String (Column (Stmt, 0)));
   exception
      when Constraint_Error => raise Storage_Error with "invalid database metadata";
   end Scalar;

   procedure Close (Target : in out SQLite_Store) is
   begin
      Finalize (Target.Database);
      Target.Owner := Null_Unbounded_String;
   end Close;

   procedure Open
     (Target : in out SQLite_Store; Path : String; Owner_ID : Text;
      Schema_Path : String := "sql/001_memory.sql")
   is
      Handle : aliased System.Address := System.Null_Address;
      Input : CS.chars_ptr;
      Status : C.int;
      Version : Natural;
      Acquired : Boolean := False;
   begin
      if Target.Database.Handle /= System.Null_Address then
         raise Storage_Error with "store is already open";
      end if;
      Validate_Text (Path);
      Validate_Text (To_String (Owner_ID));
      Input := CS.New_String (Path);
      Status := SQLite_Open (Input, Handle'Access, 6, System.Null_Address);
      CS.Free (Input);
      Target.Database.Handle := Handle;
      Acquired := True;
      if Handle = System.Null_Address then
         raise Storage_Error with "could not allocate database connection";
      end if;
      Check (Handle, Status);
      Check (Handle, Busy_Timeout (Handle, 2_000));
      Execute (Handle, "PRAGMA foreign_keys=ON;");
      if Scalar (Handle, "PRAGMA foreign_keys") /= 1 then
         raise Storage_Error with "foreign key enforcement unavailable";
      end if;
      Version := Scalar (Handle, "PRAGMA user_version");
      if Version = 0 then
         if Scalar (Handle, "SELECT count(*) FROM sqlite_master " &
                    "WHERE name NOT LIKE 'sqlite_%'") /= 0
         then
            raise Storage_Error with "refusing to initialize a nonempty database";
         end if;
         declare
            File : Ada.Text_IO.File_Type;
            SQL : Text;
         begin
            Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Schema_Path);
            while not Ada.Text_IO.End_Of_File (File) loop
               Append (SQL, Ada.Text_IO.Get_Line (File) & ASCII.LF);
            end loop;
            Ada.Text_IO.Close (File);
            Execute (Handle, To_String (SQL));
         exception
            when others =>
               if Ada.Text_IO.Is_Open (File) then
                  Ada.Text_IO.Close (File);
               end if;
               raise Storage_Error with "schema initialization failed";
         end;
      elsif Version /= 1 then
         raise Storage_Error with "unsupported schema version";
      end if;
      if Scalar (Handle, "PRAGMA user_version") /= 1 then
         raise Storage_Error with "schema version was not initialized";
      end if;
      --  Verify the expected columns exist before exposing the connection.
      declare
         Probe : Statement;
      begin
         Prepare (Handle, "SELECT id,record_kind,content,source_kind,source_ref," &
                  "recorded_utc,evidence_status,owner_id,supersedes_id " &
                  "FROM memory_event LIMIT 0", Probe);
      end;
      Target.Owner := Owner_ID;
   exception
      when others =>
         --  close_v2 rolls back an unfinished initialization transaction.
         if Acquired then
            Close (Target);
         end if;
         raise;
   end Open;

   procedure Validate_Timestamp (Input : String) is
      Stamp : constant String (1 .. Input'Length) := Input;
      Year : Ada.Calendar.Year_Number;
      Month : Ada.Calendar.Month_Number;
      Day : Ada.Calendar.Day_Number;
      Hour, Minute, Second : Natural;
      Leap : Boolean;
      Days : constant array (1 .. 12) of Natural :=
        [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
   begin
      if Stamp'Length /= 20 or else Stamp (5) /= '-' or else Stamp (8) /= '-'
        or else Stamp (11) /= 'T' or else Stamp (14) /= ':'
        or else Stamp (17) /= ':' or else Stamp (20) /= 'Z'
      then
         raise Invalid_Event with "expected UTC YYYY-MM-DDTHH:MM:SSZ";
      end if;
      for Index in Stamp'Range loop
         if Index not in 5 | 8 | 11 | 14 | 17 | 20
           and then Stamp (Index) not in '0' .. '9'
         then
            raise Invalid_Event with "timestamp contains nondigits";
         end if;
      end loop;
      Year := Ada.Calendar.Year_Number'Value (Stamp (1 .. 4));
      Month := Ada.Calendar.Month_Number'Value (Stamp (6 .. 7));
      Day := Ada.Calendar.Day_Number'Value (Stamp (9 .. 10));
      Hour := Natural'Value (Stamp (12 .. 13));
      Minute := Natural'Value (Stamp (15 .. 16));
      Second := Natural'Value (Stamp (18 .. 19));
      Leap := Year mod 4 = 0 and then (Year mod 100 /= 0 or else Year mod 400 = 0);
      if Day > Days (Month) + (if Month = 2 and Leap then 1 else 0)
        or else Hour > 23 or else Minute > 59 or else Second > 59
      then
         raise Invalid_Event with "invalid calendar date or clock time";
      end if;
   exception
      when Constraint_Error => raise Invalid_Event with "timestamp outside supported range";
   end Validate_Timestamp;

   overriding procedure Append
     (Target : in out SQLite_Store; Event : Memory_Event)
   is
      Stmt : Statement;
      DB : constant System.Address := Target.Database.Handle;
      Status : C.int;
   begin
      Require_Open (Target);
      if Event.Owner_ID /= Target.Owner then
         raise Access_Denied with "event owner differs from connection owner";
      end if;
      Validate_Text (To_String (Event.ID));
      Validate_Text (To_String (Event.Record_Kind));
      Validate_Text (To_String (Event.Content));
      Validate_Text (To_String (Event.Source_Ref));
      Validate_Text (To_String (Event.Supersedes_ID), Required => False);
      Validate_Timestamp (To_String (Event.Recorded_UTC));
      Prepare (DB, "INSERT INTO memory_event " &
               "(id,record_kind,content,source_kind,source_ref,recorded_utc," &
               "evidence_status,owner_id,supersedes_id) " &
               "VALUES (?,?,?,?,?,?,?,?,?)", Stmt);
      Bind (DB, Stmt, 1, To_String (Event.ID));
      Bind (DB, Stmt, 2, To_String (Event.Record_Kind));
      Bind (DB, Stmt, 3, To_String (Event.Content));
      Bind (DB, Stmt, 4, Ada.Characters.Handling.To_Lower (Source_Kind'Image (Event.Source)));
      Bind (DB, Stmt, 5, To_String (Event.Source_Ref));
      Bind (DB, Stmt, 6, To_String (Event.Recorded_UTC));
      Bind (DB, Stmt, 7, Ada.Characters.Handling.To_Lower (Evidence_Status'Image (Event.Evidence)));
      Bind (DB, Stmt, 8, To_String (Event.Owner_ID));
      if Length (Event.Supersedes_ID) > 0 then
         Bind (DB, Stmt, 9, To_String (Event.Supersedes_ID));
      end if;
      Status := Step (Stmt.Handle);
      if Status /= Done then
         Check (DB, Status, Event_Error => True);
      end if;
   end Append;

   overriding function Read_Event
     (Target : SQLite_Store; ID, Requester : Text) return Memory_Event
   is
      Stmt : Statement;
      DB : constant System.Address := Target.Database.Handle;
      Status : C.int;
   begin
      Require_Open (Target);
      if Requester /= Target.Owner then
         raise Access_Denied with "requester differs from connection owner";
      end if;
      Validate_Text (To_String (ID));
      Prepare (DB, "SELECT id,record_kind,content,source_kind,source_ref," &
               "recorded_utc,evidence_status,owner_id,supersedes_id " &
               "FROM memory_event WHERE id=? AND owner_id=?", Stmt);
      Bind (DB, Stmt, 1, To_String (ID));
      Bind (DB, Stmt, 2, To_String (Requester));
      Status := Step (Stmt.Handle);
      if Status = Done then
         raise Not_Found with "event not found for this owner";
      elsif Status /= Row then
         Check (DB, Status);
      end if;
      return (ID => Column (Stmt, 0), Record_Kind => Column (Stmt, 1),
              Content => Column (Stmt, 2),
              Source => Source_Kind'Value (To_String (Column (Stmt, 3))),
              Source_Ref => Column (Stmt, 4), Recorded_UTC => Column (Stmt, 5),
              Evidence => Evidence_Status'Value (To_String (Column (Stmt, 6))),
              Owner_ID => Column (Stmt, 7), Supersedes_ID => Column (Stmt, 8));
   exception
      when Constraint_Error => raise Storage_Error with "invalid stored event representation";
   end Read_Event;

   overriding procedure Erase_Owner
     (Target : in out SQLite_Store; Owner_ID, Requester : Text)
   is
      DB : constant System.Address := Target.Database.Handle;
   begin
      Require_Open (Target);
      if Requester /= Target.Owner or else Owner_ID /= Target.Owner then
         raise Access_Denied with "only the connection owner may erase its history";
      end if;
      Execute (DB, "BEGIN IMMEDIATE");
      begin
         loop
            declare
               Stmt : Statement;
               Status : C.int;
            begin
               Prepare (DB, "DELETE FROM memory_event WHERE owner_id=? AND NOT EXISTS " &
                        "(SELECT 1 FROM memory_event AS child " &
                        "WHERE child.supersedes_id=memory_event.id)", Stmt);
               Bind (DB, Stmt, 1, To_String (Owner_ID));
               Status := Step (Stmt.Handle);
               if Status /= Done then
                  Check (DB, Status);
               end if;
            end;
            exit when Changes (DB) = 0;
         end loop;
         declare
            Probe : Statement;
            Status : C.int;
         begin
            Prepare (DB, "SELECT id FROM memory_event WHERE owner_id=? LIMIT 1", Probe);
            Bind (DB, Probe, 1, To_String (Owner_ID));
            Status := Step (Probe.Handle);
            if Status = Row then
               raise Storage_Error with "history cannot be erased safely";
            elsif Status /= Done then
               Check (DB, Status);
            end if;
         end;
         Execute (DB, "COMMIT");
      exception
         when others =>
            Execute (DB, "ROLLBACK");
            raise;
      end;
   end Erase_Owner;
end Elephant_Memory.SQLite;
