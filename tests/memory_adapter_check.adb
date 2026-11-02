with Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;
with Elephant_Memory; use Elephant_Memory;
with Elephant_Memory.SQLite;

procedure Memory_Adapter_Check is
   package DB renames Elephant_Memory.SQLite;
   A, B : DB.SQLite_Store;
   E, Found : Memory_Event;
   Alice : constant Text := To_Unbounded_String ("alice");
   Bob   : constant Text := To_Unbounded_String ("bob");
   Path  : constant String := Ada.Command_Line.Argument (1);
   Mode  : constant String := Ada.Command_Line.Argument (2);
   Schema : constant String := Ada.Command_Line.Argument (3);
begin
   if Mode = "reject-open" then
      begin
         DB.Open (A, Path, Alice, Schema);
         raise Program_Error with "invalid database accepted";
      exception
         when Elephant_Memory.Storage_Error => null;
      end;
      return;
   end if;

   DB.Open (A, Path, Alice, Schema);
   begin
      DB.Open (A, Path, Bob, Schema);
      raise Program_Error with "already-open store rebound";
   exception
      when Elephant_Memory.Storage_Error => null;
   end;
   if Mode = "erase-fails" then
      begin
         DB.Erase_Owner (A, Alice, Alice);
         raise Program_Error with "injected erasure failure ignored";
      exception
         when Elephant_Memory.Storage_Error => null;
      end;
      Found := DB.Read_Event (A, To_Unbounded_String ("a"), Alice);
      Found := DB.Read_Event (A, To_Unbounded_String ("a2"), Alice);
      return;
   elsif Mode = "erase" then
      DB.Erase_Owner (A, Alice, Alice);
      begin
         Found := DB.Read_Event (A, To_Unbounded_String ("a"), Alice);
         raise Program_Error with "erased event remains";
      exception
         when Not_Found => null;
      end;
      return;
   end if;

   DB.Open (B, Path, Bob, Schema);
   E := (ID => To_Unbounded_String ("a"),
         Record_Kind => To_Unbounded_String ("note"),
         Content => To_Unbounded_String ("Original: 'quoted'; DROP TABLE memory_event; — café"),
         Source => Model_Output, Source_Ref => To_Unbounded_String ("message:1"),
         Recorded_UTC => To_Unbounded_String ("2026-11-02T23:00:00Z"),
         Evidence => Unverified, Owner_ID => Alice,
         Supersedes_ID => Null_Unbounded_String);
   if Mode = "append-fails" then
      E.ID := To_Unbounded_String ("locked");
      begin
         DB.Append (A, E);
         raise Program_Error with "competing writer ignored";
      exception
         when Elephant_Memory.Storage_Error => null;
      end;
      Found := DB.Read_Event (A, To_Unbounded_String ("a"), Alice);
      return;
   end if;
   DB.Append (A, E);
   Found := DB.Read_Event (A, E.ID, Alice);
   pragma Assert (Found = E, "all event fields must round-trip exactly");
   begin
      DB.Append (A, E);
      raise Program_Error with "duplicate event accepted";
   exception
      when Invalid_Event => null;
   end;
   E.ID := To_Unbounded_String ("b");
   E.Owner_ID := Bob;
   begin
      DB.Append (A, E);
      raise Program_Error with "cross-owner append accepted";
   exception
      when Access_Denied => null;
   end;
   DB.Append (B, E);
   begin
      Found := DB.Read_Event (A, E.ID, Alice);
      raise Program_Error with "another owner's event disclosed";
   exception
      when Not_Found => null;
   end;
   begin
      Found := DB.Read_Event (A, To_Unbounded_String ("a"), Bob);
      raise Program_Error with "unbound requester accepted";
   exception
      when Access_Denied => null;
   end;
   begin
      DB.Erase_Owner (A, Bob, Alice);
      raise Program_Error with "cross-owner erasure accepted";
   exception
      when Access_Denied => null;
   end;
   E.Owner_ID := Alice;
   E.ID := To_Unbounded_String ("a2");
   E.Supersedes_ID := To_Unbounded_String ("b");
   begin
      DB.Append (A, E);
      raise Program_Error with "cross-owner correction accepted";
   exception
      when Invalid_Event => null;
   end;
   E.Supersedes_ID := To_Unbounded_String ("missing");
   begin
      DB.Append (A, E);
      raise Program_Error with "dangling correction accepted";
   exception
      when Invalid_Event => null;
   end;
   E.Supersedes_ID := To_Unbounded_String ("a");
   declare
      Invalid_Stamps : constant array (1 .. 6) of Text :=
        [To_Unbounded_String ("2026-02-30T23:00:00Z"),
         To_Unbounded_String ("2026-11-02T24:00:00Z"),
         To_Unbounded_String ("2026-11-02T23:60:00Z"),
         To_Unbounded_String ("2026-11-02T23:00:60Z"),
         To_Unbounded_String ("2026-11-02 23:00:00Z"),
         To_Unbounded_String ("2026-11-02T23:00:00-08:00")];
   begin
      for Stamp of Invalid_Stamps loop
         E.Recorded_UTC := Stamp;
         begin
            DB.Append (A, E);
            raise Program_Error with "invalid timestamp accepted";
         exception
            when Invalid_Event => null;
         end;
      end loop;
   end;
   E.Recorded_UTC := To_Unbounded_String ("2024-02-29T23:00:00Z");
   E.ID := To_Unbounded_String ("leap");
   E.Content := To_Unbounded_String ([1 .. 20_000 => 'x']);
   DB.Append (A, E);
   Found := DB.Read_Event (A, E.ID, Alice);
   pragma Assert (Found = E, "long content and leap date must round-trip");
   E.ID := To_Unbounded_String ("a2");
   E.Recorded_UTC := To_Unbounded_String ("2026-11-02T23:00:00Z");
   E.Content := To_Unbounded_String ("Corrected words");
   E.Evidence := Supported;
   E.Source := Human_Statement;
   DB.Append (A, E);
   E.ID := To_Unbounded_String ("a3");
   E.Supersedes_ID := To_Unbounded_String ("a2");
   DB.Append (A, E);
   DB.Close (A);
   DB.Open (A, Path, Alice, Schema);
   Found := DB.Read_Event (A, E.ID, Alice);
   pragma Assert (Found = E, "correction must persist across reopen");
   Found := DB.Read_Event (A, To_Unbounded_String ("a"), Alice);
   pragma Assert (Found.Source = Model_Output and Found.Evidence = Unverified);
   DB.Close (A);
   begin
      DB.Append (A, E);
      raise Program_Error with "closed store accepted write";
   exception
      when Elephant_Memory.Storage_Error => null;
   end;
   -- B intentionally relies on automatic finalization to close its connection.
   Ada.Text_IO.Put_Line ("Ada adapter checks passed");
end Memory_Adapter_Check;
