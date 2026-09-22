using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows.Forms;
using NormaLavoro.WinForms.Data;
using NormaLavoro.WinForms.Models;

namespace NormaLavoro.WinForms
{
    public partial class MainForm : Form
    {
        private readonly VideoRepository _repo;
        public BindingList<Video> Videos { get; } = new BindingList<Video>();
n        public MainForm(VideoRepository repo)
        {
            InitializeComponent();
            _repo = repo;
            listViewVideos.FullRowSelect = true;
            listViewVideos.View = View.Details;
            listViewVideos.Columns.Add("Title", 300);
            listViewVideos.Columns.Add("FilePath", 400);
            listViewVideos.DoubleClick += ListViewVideos_DoubleClick;
            btnRefresh.Click += async (s, e) => await LoadAsync();
            btnPlay.Click += (s, e) => PlaySelected();
        }
n        protected override async void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            await LoadAsync();
        }

        private async Task LoadAsync()
        {
            var list = await _repo.GetAllAsync();
            Videos.Clear();
            listViewVideos.Items.Clear();
            foreach (var v in list)
            {
                Videos.Add(v);
                var item = new ListViewItem(new[] { v.Title, v.FilePath }) { Tag = v };
                listViewVideos.Items.Add(item);
            }
        }
n        private void PlaySelected()
        {
            if (listViewVideos.SelectedItems.Count == 0) return;
            var v = listViewVideos.SelectedItems[0].Tag as Video;
            if (v == null) return;
            if (System.IO.File.Exists(v.FilePath))
            {
                try
                {
                    Process.Start(new ProcessStartInfo(v.FilePath) { UseShellExecute = true });
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Impossibile aprire il file: {ex.Message}");
                }
            }
            else
            {
                MessageBox.Show("File non trovato: " + v.FilePath);
            }
        }
n        private void ListViewVideos_DoubleClick(object sender, EventArgs e) { PlaySelected(); }
    }
}