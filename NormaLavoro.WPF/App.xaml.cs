using System.Windows;
using Microsoft.EntityFrameworkCore;
using NormaLavoro.Data;

namespace NormaLavoro
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            var options = new DbContextOptionsBuilder<NormaLavoroContext>()
                .UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=NormaLavoro;Trusted_Connection=True;")
                .Options;

            var ctx = new NormaLavoroContext(options);
            var main = new Views.MainWindow(ctx);
            main.Show();
        }
    }
}
