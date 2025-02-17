Here is the **README.md** in English for your Calculator App project:  

---

# 🧮 Calculator App  

A simple **Flutter-based** calculator application.  

## 📌 Features  
- Basic mathematical operations (+, -, ×, ÷)  
- Simple and responsive UI  
- Supports light and dark mode  
- Custom theme support  

## 🚀 Installation & Running the Project  

Ensure you have **Flutter** and **Dart** installed on your system.  

1️⃣ Clone this repository:  
```bash  
git clone https://github.com/pakelcomedy/Calculator-App.git  
cd Calculator-App  
```  

2️⃣ Install dependencies:  
```bash  
flutter pub get  
```  

3️⃣ Run the app on an emulator or device:  
```bash  
flutter run  
```  

## 🛠️ Bug Fixes  
If you encounter the error **"The named parameter 'backgroundColor' isn't defined"**, it's likely that **this parameter has been deprecated** in the latest Flutter version.  

**Solution:**  
Replace `backgroundColor` with the correct parameter based on the latest Flutter version, such as:  
```dart  
color: Colors.grey.shade200 // Adjust as needed  
```  

If other errors occur, ensure that you **check your Flutter version** and update dependencies with:  
```bash  
flutter upgrade  
flutter pub upgrade  
```  

## 📜 License  
This project is licensed under the **MIT License**. Feel free to use and modify it as needed.  

---