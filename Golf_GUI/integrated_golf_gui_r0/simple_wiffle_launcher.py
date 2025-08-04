#!/usr/bin/env python3
"""
Simple Wiffle Swing Visualizer Launcher
Loads and displays Wiffle golf swing data without comparison functionality
"""

import sys
import os
from pathlib import Path

# Add the current directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

try:
    from PyQt6.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QWidget, QPushButton, QLabel, QFileDialog, QMessageBox
    from PyQt6.QtCore import Qt, QThread, pyqtSignal
    from PyQt6.QtGui import QFont
    
    # Import the existing GUI components
    from golf_gui_application import GolfVisualizerMainWindow
    from wiffle_data_loader import WiffleDataLoader, WiffleDataConfig
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Please install required dependencies: pip install -r requirements.txt")
    sys.exit(1)

class DataLoadingThread(QThread):
    """Thread for loading Excel data in background"""
    data_loaded = pyqtSignal(object, object, object)  # baseq, ztcfq, deltaq
    error_occurred = pyqtSignal(str)
    
    def __init__(self, excel_file_path):
        super().__init__()
        self.excel_file_path = excel_file_path
    
    def run(self):
        try:
            # Load Wiffle data
            config = WiffleDataConfig(
                normalize_time=True,
                filter_noise=True,
                interpolate_missing=True
            )
            
            loader = WiffleDataLoader(config)
            excel_data = loader.load_excel_data(self.excel_file_path)
            baseq, ztcfq, deltaq = loader.convert_to_gui_format(excel_data)
            
            # Use Wiffle data as primary (ztcfq)
            self.data_loaded.emit(ztcfq, ztcfq, deltaq)
            
        except Exception as e:
            self.error_occurred.emit(str(e))

class SimpleWiffleLauncher(QMainWindow):
    """Simple launcher for Wiffle swing visualization"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Wiffle Swing Visualizer - Launcher")
        self.setGeometry(100, 100, 600, 400)
        
        # Setup UI
        self.setup_ui()
        
        # Store the main window reference
        self.main_window = None
        
    def setup_ui(self):
        """Setup the user interface"""
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        layout = QVBoxLayout(central_widget)
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        # Title
        title = QLabel("Wiffle Swing Visualizer")
        title.setFont(QFont("Arial", 20, QFont.Weight.Bold))
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)
        
        # Subtitle
        subtitle = QLabel("Load and visualize Wiffle golf swing data")
        subtitle.setFont(QFont("Arial", 12))
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(subtitle)
        
        layout.addSpacing(30)
        
        # Auto-load button (uses default Excel file)
        self.auto_load_btn = QPushButton("🚀 Auto-Load Wiffle Data")
        self.auto_load_btn.setFont(QFont("Arial", 14))
        self.auto_load_btn.setMinimumHeight(50)
        self.auto_load_btn.clicked.connect(self.auto_load_data)
        layout.addWidget(self.auto_load_btn)
        
        layout.addSpacing(20)
        
        # Manual load button
        self.manual_load_btn = QPushButton("📁 Choose Excel File")
        self.manual_load_btn.setFont(QFont("Arial", 14))
        self.manual_load_btn.setMinimumHeight(50)
        self.manual_load_btn.clicked.connect(self.manual_load_data)
        layout.addWidget(self.manual_load_btn)
        
        layout.addSpacing(30)
        
        # Status label
        self.status_label = QLabel("Ready to load Wiffle swing data")
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.status_label.setStyleSheet("color: gray;")
        layout.addWidget(self.status_label)
        
        # Find default Excel file
        self.default_excel_file = self.find_default_excel_file()
        if self.default_excel_file:
            self.status_label.setText(f"Default file found: {self.default_excel_file.name}")
        else:
            self.status_label.setText("No default Excel file found - use manual load")
            self.auto_load_btn.setEnabled(False)
    
    def find_default_excel_file(self):
        """Find the default Excel file"""
        possible_paths = [
            Path("../Matlab Inverse Dynamics/Wiffle_ProV1_club_3D_data.xlsx"),
            Path("../../Matlab Inverse Dynamics/Wiffle_ProV1_club_3D_data.xlsx"),
            Path("../../../Matlab Inverse Dynamics/Wiffle_ProV1_club_3D_data.xlsx"),
            Path("Matlab Inverse Dynamics/Wiffle_ProV1_club_3D_data.xlsx")
        ]
        
        for path in possible_paths:
            if path.exists():
                return path
        
        return None
    
    def auto_load_data(self):
        """Auto-load the default Excel file"""
        if self.default_excel_file:
            self.load_data(self.default_excel_file)
        else:
            QMessageBox.warning(self, "File Not Found", "Default Excel file not found. Please use manual load.")
    
    def manual_load_data(self):
        """Manually select and load Excel file"""
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Select Wiffle_ProV1 Excel File",
            "",
            "Excel Files (*.xlsx *.xls)"
        )
        
        if file_path:
            self.load_data(Path(file_path))
    
    def load_data(self, excel_file_path):
        """Load data from Excel file"""
        self.status_label.setText("Loading data...")
        self.auto_load_btn.setEnabled(False)
        self.manual_load_btn.setEnabled(False)
        
        # Start loading thread
        self.loading_thread = DataLoadingThread(str(excel_file_path))
        self.loading_thread.data_loaded.connect(self.on_data_loaded)
        self.loading_thread.error_occurred.connect(self.on_error)
        self.loading_thread.start()
    
    def on_data_loaded(self, baseq, ztcfq, deltaq):
        """Called when data is successfully loaded"""
        self.status_label.setText("Data loaded successfully! Opening visualizer...")
        
        # Create and show the main visualization window
        self.main_window = GolfVisualizerMainWindow()
        self.main_window.setWindowTitle("Wiffle Swing Visualizer")
        
        # Set the data
        self.main_window.load_data_from_dataframes(baseq, ztcfq, deltaq)
        
        # Show the window
        self.main_window.show()
        
        # Close the launcher
        self.close()
    
    def on_error(self, error_message):
        """Called when an error occurs during loading"""
        self.status_label.setText("Error loading data")
        self.auto_load_btn.setEnabled(True)
        self.manual_load_btn.setEnabled(True)
        
        QMessageBox.critical(self, "Loading Error", f"Failed to load data:\n{error_message}")

def main():
    """Main function"""
    app = QApplication(sys.argv)
    
    # Set application style
    app.setStyle('Fusion')
    
    # Create and show launcher
    launcher = SimpleWiffleLauncher()
    launcher.show()
    
    # Run the application
    sys.exit(app.exec())

if __name__ == "__main__":
    main() 