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

![Uploading SimulatorScreenRecording-iPhone13mini-2025-04-02at13.22.53-ezgif.com-video-to-gif-converter.gif](https://github.com/user-attachments/assets/1cb433f2-8a6b-4986-bd4d-b36622c0b356)
