using System;
using System.Drawing;
using System.IO;

class Program
{
  static void Main()
  {
    var bmp = new Bitmap("example.png");
    var stream = File.OpenWrite("example.bit");
    for(int y = 0; y < 128; y++)
    {
      for(int x = 0; x < 256; x++)
      {
        var c = bmp.GetPixel(x, y);
        var g = c.R;
        var a = (ushort)(0x8000 | (y << 8) | x);

        stream.WriteByte((byte)'B');

        stream.WriteByte((byte)(a));
        stream.WriteByte((byte)(a >> 8));
        
        if(g > 192)
          stream.WriteByte(3);
        else if(g > 128)
          stream.WriteByte(2);
        else if(g > 64)
          stream.WriteByte(1);
        else
          stream.WriteByte(0);
      }
    }
  }
}