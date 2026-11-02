with Ada.Finalization;
with System;

package Elephant_Memory.SQLite is
   type SQLite_Store is new Store with private;

   --  Owner_ID must come from a trusted caller's authenticated session, never
   --  from an untrusted request. This package does not implement user login.
   --  A store is used by one Ada task at a time. Separate stores may share a DB.
   procedure Open
     (Target : in out SQLite_Store; Path : String; Owner_ID : Text;
      Schema_Path : String := "sql/001_memory.sql");
   procedure Close (Target : in out SQLite_Store);

   overriding procedure Append
     (Target : in out SQLite_Store; Event : Memory_Event);
   overriding function Read_Event
     (Target : SQLite_Store; ID, Requester : Text) return Memory_Event;
   overriding function List_Events
     (Target : SQLite_Store; Requester : Text; Include_History : Boolean := False;
      Limit : Page_Size := 50; Offset : Natural := 0) return Event_Page;
   overriding function Search_Events
     (Target : SQLite_Store; Requester, Query : Text; Include_History : Boolean := False;
      Limit : Page_Size := 50; Offset : Natural := 0) return Event_Page;
   overriding procedure Erase_Owner
     (Target : in out SQLite_Store; Owner_ID, Requester : Text);

private
   type Connection is new Ada.Finalization.Limited_Controlled with record
      Handle : System.Address := System.Null_Address;
   end record;
   overriding procedure Finalize (Item : in out Connection);

   type SQLite_Store is new Store with record
      Database : Connection;
      Owner : Text;
   end record;
end Elephant_Memory.SQLite;
