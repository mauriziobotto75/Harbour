using System;
using System.Windows.Forms;
using Microsoft.EntityFrameworkCore;
using NormaLavoro.WinForms.Data;

namespace NormaLavoro.WinForms
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.SetHighDpiMode(HighDpiMode.SystemAware);
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
n            var options = new DbContextOptionsBuilder<NormaLavoroContext>()
                .UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=NormaLavoro;Trusted_Connection=True;")
                .Options;
n            using var ctx = new NormaLavoroContext(options);
            var repo = new VideoRepository(ctx);
            Application.Run(new MainForm(repo));
        }
    }
}