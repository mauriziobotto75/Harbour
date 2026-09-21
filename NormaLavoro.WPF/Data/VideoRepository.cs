using Microsoft.EntityFrameworkCore;
using NormaLavoro.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace NormaLavoro.Data
{
    public class VideoRepository
    {
        private readonly NormaLavoroContext _ctx;
        public VideoRepository(NormaLavoroContext ctx) => _ctx = ctx;

        public Task<List<Video>> GetAllAsync() =>
            _ctx.Videos.AsNoTracking().OrderByDescending(v => v.UploadedAt).ToListAsync();

        public Task<Video?> GetByIdAsync(int id) =>
            _ctx.Videos.FindAsync(id).AsTask();
    }
}