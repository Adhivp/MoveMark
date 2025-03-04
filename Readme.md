# MoveMark - Gait Recognition Attendance System

MoveMark is an innovative attendance management system that uses gait recognition to identify and mark attendance. The project combines cutting-edge gait recognition technology with a modern web interface to provide a seamless attendance tracking experience.

## Project Structure

The project consists of three main components:

### 1. MoveMark Frontend (`movemark-frontend/`)
- Built with Flutter
- Modern and responsive Material Design UI
- Features:
  - Dashboard for attendance analytics
  - Gait registration and recognition interface
  - Leave management system
  - Calendar view
  - Employee management
  - Real-time notifications
- Cross-platform support (Web, Android, iOS)

### 2. MoveMark Backend (`MoveMark_backend/`)
- Built with FastAPI
- RESTful API endpoints for:
  - User management
  - Attendance tracking
  - Leave requests
  - Analytics
- Features:
  - JWT authentication
  - Real-time data processing
  - Integration with GaitRecognitionSystem
  - Efficient database operations

### 3. Gait Recognition System (`GaitRecognitionSystem/`)
- Based on research by Han Yuanyuan (韩园园) from Dalian University of Technology
- Implementation of deep learning-based gait recognition
- Core components:
  - Person detection using YOLOv5
  - Gait feature extraction
  - Silhouette generation
  - OpenGait integration
  - Real-time video processing
- model folder has been removed due to size issues in github
- take the video folder and train the videos
- clone the starting the model folder from their original repo     https://github.com/jackhanyuan/GaitRecognitionSystem

### 4. MoveMark Mobile App (`movemark-app/`)
- Built with Flutter
- Native mobile application for Android and iOS
- Features:
  - Attendance confirmation
  - Filter Attendance by day
  - Employee leave management
  - Leave request submission
  - Leave status tracking
  - Push notifications
- Key components:
  - Cross-platform mobile UI
  - Secure API integration
  - Local data persistence


### 5. Assets (`assets-logo,ppt,demo-video...`)
- Project documentation
- Presentation materials
- Demo videos
- Logo and branding assets

## Technology Stack

- **Frontend**: Flutter, Dart
- **Backend**: FastAPI, Python
- **Database**: SQLite/PostgreSQL
- **ML/DL Framework**: PyTorch, OpenGait
- **Object Detection**: YOLOv5
- **Video Processing**: OpenCV

## Research Credits

This project implements gait recognition based on the following research:

```bibtex
@mastersthesis{韩园园2023基于深度学习的步态识别与比较系统,
  title={基于深度学习的步态识别与比较系统},
  author={韩园园},
  year={2023},
  school={大连理工大学}
}

@inproceedings{han2022gaitpretreatment,
  title={GaitPretreatment: Robust Pretreatment Strategy for Gait Recognition},
  author={Han, Yuanyuan and Wang, Zhong and Han, Xin and Fan, Xiaoya},
  booktitle={2022 International Conference on Communications, Computing, Cybersecurity, and Informatics (CCCI)},
  pages={1-6},
  year={2022},
  organization={IEEE}
}
```

Original gait recognition implementation: https://github.com/jackhanyuan/GaitRecognitionSystem