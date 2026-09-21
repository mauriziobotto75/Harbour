using Microsoft.EntityFrameworkCore;
using NormaLavoro.WinForms.Models;

namespace NormaLavoro.WinForms.Data
{
    public class NormaLavoroContext : DbContext
    {
        public DbSet<Video> Videos { get; set; } = null!;

        public NormaLavoroContext(DbContextOptions<NormaLavoroContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Video>(b =>
            {
                b.Property(v => v.Title).IsRequired().HasMaxLength(300);
                b.Property(v => v.FilePath).IsRequired().HasMaxLength(2000);
            });
        }
    }
}