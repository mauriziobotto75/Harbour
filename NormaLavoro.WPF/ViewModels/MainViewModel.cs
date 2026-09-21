using System.Collections.ObjectModel;
using System.Threading.Tasks;
using NormaLavoro.Models;
using NormaLavoro.Data;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace NormaLavoro.ViewModels
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private readonly VideoRepository _repo;
        public ObservableCollection<Video> Videos { get; } = new();
        private Video? _selectedVideo;
        public Video? SelectedVideo { get => _selectedVideo; set { _selectedVideo = value; OnPropertyChanged(); } }

        public RelayCommand RefreshCommand { get; }
        public RelayCommand PlayCommand { get; }

        public MainViewModel(VideoRepository repo)
        {
            _repo = repo;
            RefreshCommand = new RelayCommand(async _ => await LoadAsync());
            PlayCommand = new RelayCommand(_ => { }, _ => SelectedVideo != null);
        }

        public async Task LoadAsync()
        {
            var list = await _repo.GetAllAsync();
            Videos.Clear();
            foreach (var v in list) Videos.Add(v);
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? n = null) =>
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));
    }
}