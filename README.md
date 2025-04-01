# ToDoList App (Тестовое задание Effective Mobile)

## Архитектура и Технологии

* **Архитектура:** Модульная, основанная на принципах **VIPER** (View, Interactor, Presenter, Router) с небольшими адаптациями. Используется **Builder** для сборки модулей и внедрения зависимостей.
* **Язык:** Swift
* **UI:** UIKit (верстка кодом, без Storyboards/XIBs)
* **Хранение данных:** Core Data (FRC + NSBatchInsertRequest)
* **Сеть:** URLSession (через обертку `NetworkClient`), Decodable
* **Тестирование:** Unit-тесты для Presenter'ов, Interactor'ов, Loader, Store, Model, Утилит с использованием моков и in-memory store для Core Data).
* **Зависимости:** Только стандартные фреймворки Apple.

---

## Демонстрация работы

![SimulatorScreenRecording-iPhone13mini-2025-03-31at22 01 12-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/95b6ea6b-d2c8-4016-ab52-c2f85ad8215f)
