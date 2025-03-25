import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { RouterModule, Routes } from '@angular/router';
import { FileReaderComponent } from './file-reader/file-reader.component';
import { FileUploadComponent } from './file-upload/file-upload.component';

const routes: Routes = [
  { path: '', component: FileReaderComponent }, // Default route
  { path: 'reader', component: FileReaderComponent },
  { path: 'upload', component: FileUploadComponent },
  //{ path: 'read-files' } // Wildcard route for unknown paths
];

export const appConfig: ApplicationConfig = {
  providers: [provideHttpClient(),provideZoneChangeDetection({ eventCoalescing: true }), provideRouter(routes)]
};
