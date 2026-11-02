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

   type Store is abstract tagged limited null record;
   Storage_Error, Invalid_Event, Access_Denied, Not_Found : exception;

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

   --  Explicitly authorized erasure removes an owner's complete history.
   --  The adapter must also handle exports/backups under the retention policy.
   procedure Erase_Owner
     (Target : in out Store; Owner_ID, Requester : Text) is abstract;
end Elephant_Memory;
