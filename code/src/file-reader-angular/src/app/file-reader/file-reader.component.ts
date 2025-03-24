import { Component, OnInit, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';

interface dataModel {
  Request: string;
  'Sub Request': string;
  'Confidence Score': string;
  isDuplicate: string;
}

@Component({
  selector: 'app-file-reader',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './file-reader.component.html',
  styleUrls: ['./file-reader.component.css'],
})
export class FileReaderComponent implements OnInit {
  fileContent: any[] = [];
  errorMessage = '';
  fileList: any = '';
  private http = inject(HttpClient);

  ngOnInit() {
    this.http
      .get<{ files: string[] }>('http://localhost:3000/files')
      .subscribe((data) => {
        this.readTextFile(data.files);
      });
  }

  readTextFile(fileList: string[]) {
    fileList.forEach((file: string) => {
      if (file.indexOf('.') >= 0) {// ignoring folders
        this.http
          .get('/assets/' + file, { responseType: 'json' }) // ✅ Ensure correct file path
          .subscribe(
            (data) => {
              this.fileContent.push(JSON.parse(JSON.stringify(data)));
            },
            (error) => {
              console.error('Error loading text file:', error);
              this.errorMessage = 'Error loading file!';
            }
          );
      }
    });
  }
}
