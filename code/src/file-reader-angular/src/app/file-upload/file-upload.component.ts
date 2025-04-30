import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';

@Component({
  selector: 'app-file-upload',
  imports: [CommonModule],
  templateUrl: './file-upload.component.html',
  styleUrls: ['./file-upload.component.css'],
})
export class FileUploadComponent {
  fileContent: string | null = null;
  loading: boolean = false;
  // Method to handle file selection
  onFileSelected(event: any): void {
    this.loading = true;

    const file: File = event.target.files[0]; // Get the first selected file
    if (file) {
      const reader = new FileReader();
      reader.readAsText(file); // Read the file as text

      reader.onload = () => {
        // Set the file content when read is complete
        this.fileContent = reader.result as string;
      };

      reader.onerror = (error) => {
        console.error('Error reading file:', error);
        this.fileContent = 'Error reading file';
      };
      this.loading = false;
    }
  }
}
