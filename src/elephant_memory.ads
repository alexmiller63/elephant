with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

--  Proposed storage contract. No provider calls or background work.
package Elephant_Memory is
   subtype Text is Ada.Strings.Unbounded.Unbounded_String;
   type Source_Kind is
     (Human_Statement, External_Source, Hypothesis, Model_Output,
      Verified_Outcome, Tool_Output);
   type Evidence_Status is (Unverified, Supported, Disputed, Verified);

   type Memory_Event is record
      ID             : Text;
      Record_Kind    : Text;
      Content        : Text;
      Source         : Source_Kind;
      Source_Ref     : Text;
      Recorded_UTC   : Text; -- UTC ISO 8601, YYYY-MM-DDTHH:MM:SSZ
      Evidence       : Evidence_Status := Unverified;
      Owner_ID       : Text;
      Supersedes_ID  : Text; -- Empty for an original event
   end record;

   type Memory_Hit is record
      Item : Memory_Event;
      Is_Current : Boolean;
   end record;
   package Hit_Vectors is new Ada.Containers.Vectors
     (Index_Type => Positive, Element_Type => Memory_Hit);
   subtype Page_Size is Positive range 1 .. 100;
   Maximum_Query_Bytes : constant Positive := 4_096;
   type Event_Page is record
      Items : Hit_Vectors.Vector;
      Has_More : Boolean := False;
   end record;

   type Store is abstract tagged limited null record;
   Storage_Error, Invalid_Event, Access_Denied, Not_Found : exception;
   Invalid_Query : exception;

   --  Append atomically; reject duplicate IDs, missing provenance, and
   --  corrections to missing events or events belonging to another owner.
   --  Never overwrite an existing event. An adapter maps enum values to
   --  the corresponding lower-case SQL tokens in sql/001_memory.sql.
   procedure Append
     (Target : in out Store; Event : Memory_Event) is abstract;

   --  Requester must match Owner_ID. Authorization is the adapter's duty;
   --  SQLite constraints alone do not provide an access-control boundary.
   function Read_Event
     (Target : Store; ID, Requester : Text) return Memory_Event is abstract;

   --  Newest recorded UTC first, then ID ascending for timestamp ties.
   --  Current leaves only unless Include_History is True. Is_Current and
   --  Supersedes_ID distinguish historical originals from corrections;
   --  multiple correction branches are preserved without choosing truth.
   --  Offset pagination is stable only while the underlying records do not
   --  change. Each page is one database snapshot, not a multi-page snapshot.
   function List_Events
     (Target : Store; Requester : Text; Include_History : Boolean := False;
      Limit : Page_Size := 50; Offset : Natural := 0) return Event_Page is abstract;

   --  Literal substring search of content, ASCII case insensitive. Non-ASCII
   --  bytes must match exactly. Query must be nonblank, NUL-free, and at most
   --  Maximum_Query_Bytes bytes. Invalid search text raises Invalid_Query.
   function Search_Events
     (Target : Store; Requester, Query : Text; Include_History : Boolean := False;
      Limit : Page_Size := 50; Offset : Natural := 0) return Event_Page is abstract;

   --  Explicitly authorized erasure removes an owner's complete history.
   --  The adapter must also handle exports/backups under the retention policy.
   procedure Erase_Owner
     (Target : in out Store; Owner_ID, Requester : Text) is abstract;
end Elephant_Memory;
