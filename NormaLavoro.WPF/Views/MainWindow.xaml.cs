using System.Windows;
using NormaLavoro.Data;
using NormaLavoro.ViewModels;

namespace NormaLavoro.Views
{
    public partial class MainWindow : Window
    {
        private readonly MainViewModel _vm;
        public MainWindow(NormaLavoroContext ctx)
        {
            InitializeComponent();
            var repo = new VideoRepository(ctx);
            _vm = new MainViewModel(repo);
            DataContext = _vm;
            Loaded += MainWindow_Loaded;
        }

        private async void MainWindow_Loaded(object? s, RoutedEventArgs e)
        {
            await _vm.LoadAsync();
            _vm.PropertyChanged += Vm_PropertyChanged;
        }

        private void Vm_PropertyChanged(object? s, System.ComponentModel.PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(MainViewModel.SelectedVideo))
            {
                var v = _vm.SelectedVideo;
                if (v != null && System.IO.File.Exists(v.FilePath))
                {
                    mediaPlayer.Source = new System.Uri(v.FilePath);
                    mediaPlayer.Stop();
                    mediaPlayer.Play();
                }
                else
                {
                    mediaPlayer.Stop();
                    mediaPlayer.Source = null;
                }
            }
        }
    }
}