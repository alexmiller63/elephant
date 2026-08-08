with Ada.Text_IO;

procedure Elephant is

   Memory : String (1 .. 1000);

   Last   : Natural;

begin

   Ada.Text_IO.Put ("Memory: ");

   Ada.Text_IO.Get_Line (Memory, Last);

   Ada.Text_IO.Put_Line ("I remember: " & Memory (1 .. Last));

end Elephant;

