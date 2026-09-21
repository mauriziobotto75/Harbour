namespace NormaLavoro.WinForms
{
    partial class MainForm
    {
        private System.ComponentModel.IContainer components = null;
        private System.Windows.Forms.ListView listViewVideos;
        private System.Windows.Forms.Button btnRefresh;
        private System.Windows.Forms.Button btnPlay;
n        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }
n        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.listViewVideos = new System.Windows.Forms.ListView();
            this.btnRefresh = new System.Windows.Forms.Button();
            this.btnPlay = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // listViewVideos
            // 
            this.listViewVideos.HideSelection = false;
            this.listViewVideos.Location = new System.Drawing.Point(12, 12);
            this.listViewVideos.Name = "listViewVideos";
            this.listViewVideos.Size = new System.Drawing.Size(760, 360);
            this.listViewVideos.TabIndex = 0;
            this.listViewVideos.UseCompatibleStateImageBehavior = false;
            // 
            // btnRefresh
            // 
            this.btnRefresh.Location = new System.Drawing.Point(12, 380);
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(100, 30);
            this.btnRefresh.TabIndex = 1;
            this.btnRefresh.Text = "Aggiorna";
            this.btnRefresh.UseVisualStyleBackColor = true;
            // 
            // btnPlay
            // 
            this.btnPlay.Location = new System.Drawing.Point(118, 380);
            this.btnPlay.Name = "btnPlay";
            this.btnPlay.Size = new System.Drawing.Size(100, 30);
            this.btnPlay.TabIndex = 2;
            this.btnPlay.Text = "Riproduci";
            this.btnPlay.UseVisualStyleBackColor = true;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(784, 421);
            this.Controls.Add(this.btnPlay);
            this.Controls.Add(this.btnRefresh);
            this.Controls.Add(this.listViewVideos);
            this.Name = "MainForm";
            this.Text = "NormaLavoro";
            this.ResumeLayout(false);
        }
    }
}