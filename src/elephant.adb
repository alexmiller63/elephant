with Ada.Text_IO;

procedure Elephant is

   Memory_ID   : constant String := "000001";

   Memory      : String (1 .. 1000);

   Last        : Natural;

   Memory_File : Ada.Text_IO.File_Type;

begin

   Ada.Text_IO.Put ("Memory: ");

   Ada.Text_IO.Get_Line (Memory, Last);

   Ada.Text_IO.Create

     (File => Memory_File,

      Mode => Ada.Text_IO.Out_File,

      Name => "memories/" & Memory_ID & ".txt");

   Ada.Text_IO.Put_Line

     (File => Memory_File,

      Item => Memory (1 .. Last));

   Ada.Text_IO.Close (Memory_File);

   Ada.Text_IO.Put_Line ("Memory " & Memory_ID & " saved.");

end Elephant;

