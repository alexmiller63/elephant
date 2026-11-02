with Ada.Command_Line; use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Elephant_Memory; use Elephant_Memory;
with Elephant_Memory.SQLite;

procedure Memory_Retrieval_Check is
   package DB renames Elephant_Memory.SQLite;
   Target : DB.SQLite_Store;
   Owner : constant Text := To_Unbounded_String (Argument (2));
   Requester : constant Text := To_Unbounded_String (Argument (3));
   Mode : constant String := Argument (4);
   Query : Text := To_Unbounded_String (Argument (5));
   History : constant Boolean := Boolean'Value (Argument (6));
   Limit : constant Page_Size := Page_Size'Value (Argument (7));
   Offset : constant Natural := Natural'Value (Argument (8));
   Page : Event_Page;
begin
   DB.Open (Target, Argument (1), Owner);
   if Mode = "closed" then
      DB.Close (Target);
   elsif Mode = "nul" then
      Query := To_Unbounded_String ("star" & Character'Val (0));
   end if;
   if Mode = "list" or else Mode = "closed" then
      Page := DB.List_Events (Target, Requester, History, Limit, Offset);
   else
      Page := DB.Search_Events (Target, Requester, Query, History, Limit, Offset);
   end if;
   for Hit of Page.Items loop
      -- Test fixtures use no tabs/newlines, so metadata can be checked
      -- independently by the Python caller without a production JSON library.
      Put_Line (To_String (Hit.Item.ID) & ASCII.HT &
                Boolean'Image (Hit.Is_Current) & ASCII.HT &
                To_String (Hit.Item.Supersedes_ID) & ASCII.HT &
                Source_Kind'Image (Hit.Item.Source) & ASCII.HT &
                Evidence_Status'Image (Hit.Item.Evidence) & ASCII.HT &
                To_String (Hit.Item.Content) & ASCII.HT &
                To_String (Hit.Item.Source_Ref) & ASCII.HT &
                To_String (Hit.Item.Record_Kind) & ASCII.HT &
                To_String (Hit.Item.Recorded_UTC) & ASCII.HT &
                To_String (Hit.Item.Owner_ID));
   end loop;
   Put_Line ("MORE=" & Boolean'Image (Page.Has_More));
exception
   when Access_Denied => Put_Line ("ERROR=Access_Denied");
   when Invalid_Query => Put_Line ("ERROR=Invalid_Query");
   when Elephant_Memory.Storage_Error => Put_Line ("ERROR=Storage_Error");
end Memory_Retrieval_Check;
