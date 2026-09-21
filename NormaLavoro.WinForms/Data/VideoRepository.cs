using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using NormaLavoro.WinForms.Models;

namespace NormaLavoro.WinForms.Data
{
    public class VideoRepository
    {
        private readonly NormaLavoroContext _ctx;
        public VideoRepository(NormaLavoroContext ctx) => _ctx = ctx;
n        public Task<List<Video>> GetAllAsync() =>
            _ctx.Videos.AsNoTracking().OrderByDescending(v => v.UploadedAt).ToListAsync();
n        public async Task<Video> GetByIdAsync(int id)
        {
            var v = await _ctx.Videos.FindAsync(id);
            return v!;
        }
    }
}