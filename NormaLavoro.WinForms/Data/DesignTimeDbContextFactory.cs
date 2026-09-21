using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace NormaLavoro.WinForms.Data
{
    public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<NormaLavoroContext>
    {
        public NormaLavoroContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<NormaLavoroContext>();
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=NormaLavoro;Trusted_Connection=True;");
            return new NormaLavoroContext(optionsBuilder.Options);
        }
    }
}