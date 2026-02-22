workspace "TaskPlanner" "Система планирования задач" {
    !identifiers hierarchical

    model {
        user = person "Пользователь" "Конечный пользователь системы"

        taskPlanner = softwareSystem "TaskPlanner" "Система планирования задач" {
            description "Приложение для планирования задач с целями и задачами"

            apiGateway = container "API Gateway" "Точка входа для API запросов" "Golang"
            userService = container "Сервис пользователей" "Управление пользователями" "Golang"
            goalService = container "Сервис целей" "Управление целями" "Golang"
            taskService = container "Сервис задач" "Управление задачами" "Golang"
            database = container "База данных" "Хранение данных" "PostgreSQL" {
                tags "database"
            }
        }

        user -> taskPlanner.apiGateway "Отправляет API запросы"
        taskPlanner.apiGateway -> taskPlanner.userService "Маршрутизирует запросы пользователей REST"
        taskPlanner.apiGateway -> taskPlanner.goalService "Маршрутизирует запросы целей REST"
        taskPlanner.apiGateway -> taskPlanner.taskService "Маршрутизирует запросы задач REST"
        taskPlanner.userService -> taskPlanner.database "Читает/записывает данные пользователей (JDBC)"
        taskPlanner.goalService -> taskPlanner.database "Читает/записывает данные целей (JDBC)"
        taskPlanner.taskService -> taskPlanner.database "Читает/записывает данные задач (JDBC)"
        taskPlanner.userService -> taskPlanner.goalService "Получает информацию о пользователях REST"
        taskPlanner.taskService -> taskPlanner.userService "Получает информацию о пользователях REST"
        taskPlanner.taskService -> taskPlanner.goalService "Получает информацию о целях REST"
    }

    views {
        themes default

        properties {
            structurizr.tooltips true
        }

        systemContext taskPlanner "SystemContext" {
            include *
            autoLayout
        }

        container taskPlanner "Container" {
            include *
            autoLayout
        }

        dynamic taskPlanner "UseCase1" "Создание нового пользователя" {
            autoLayout
            user -> taskPlanner.apiGateway "POST /api/users"
            taskPlanner.apiGateway -> taskPlanner.userService "Создать пользователя"
            taskPlanner.userService -> taskPlanner.database "Сохранить данные пользователя"
            taskPlanner.database -> taskPlanner.userService "Возвращает ID"
            taskPlanner.userService -> taskPlanner.apiGateway "Возвращает пользователя"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase2" "Поиск пользователя по логину" {
            autoLayout
            user -> taskPlanner.apiGateway "GET /api/users/search?login={login}"
            taskPlanner.apiGateway -> taskPlanner.userService "Найти пользователя"
            taskPlanner.userService -> taskPlanner.database "Запрос по логину"
            taskPlanner.database -> taskPlanner.userService "Возвращает данные"
            taskPlanner.userService -> taskPlanner.apiGateway "Возвращает пользователя"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase3" "Поиск пользователя по маске имени и фамилии" {
            autoLayout
            user -> taskPlanner.apiGateway "GET /api/users/search?nameMask={mask}"
            taskPlanner.apiGateway -> taskPlanner.userService "Поиск по маске"
            taskPlanner.userService -> taskPlanner.database "Запрос с LIKE"
            taskPlanner.database -> taskPlanner.userService "Возвращает список"
            taskPlanner.userService -> taskPlanner.apiGateway "Возвращает список"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase4" "Создание новой цели" {
            autoLayout
            user -> taskPlanner.apiGateway "POST /api/goals"
            taskPlanner.apiGateway -> taskPlanner.goalService "Создать цель"
            taskPlanner.goalService -> taskPlanner.database "Сохранить цель"
            taskPlanner.database -> taskPlanner.goalService "Возвращает ID"
            taskPlanner.goalService -> taskPlanner.apiGateway "Возвращает цель"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase5" "Получение списка всех целей" {
            autoLayout
            user -> taskPlanner.apiGateway "GET /api/goals"
            taskPlanner.apiGateway -> taskPlanner.goalService "Получить все цели"
            taskPlanner.goalService -> taskPlanner.database "Запрос всех целей"
            taskPlanner.database -> taskPlanner.goalService "Возвращает список"
            taskPlanner.goalService -> taskPlanner.apiGateway "Возвращает цели"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase6" "Создание новой задачи на пути к цели" {
            autoLayout
            user -> taskPlanner.apiGateway "POST /api/goals/{goalId}/tasks"
            taskPlanner.apiGateway -> taskPlanner.taskService "Создать задачу"
            taskPlanner.taskService -> taskPlanner.goalService "Проверить цель"
            taskPlanner.goalService -> taskPlanner.database "Проверить что существует"
            taskPlanner.database -> taskPlanner.goalService "Возвращает цель"
            taskPlanner.goalService -> taskPlanner.taskService "Подтверждение"
            taskPlanner.taskService -> taskPlanner.database "Сохранить задачу"
            taskPlanner.database -> taskPlanner.taskService "Возвращает ID"
            taskPlanner.taskService -> taskPlanner.apiGateway "Возвращает задачу"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase7" "Получение всех задач цели" {
            autoLayout
            user -> taskPlanner.apiGateway "GET /api/goals/{goalId}/tasks"
            taskPlanner.apiGateway -> taskPlanner.taskService "Получить задачи"
            taskPlanner.taskService -> taskPlanner.goalService "Проверить цель"
            taskPlanner.goalService -> taskPlanner.database "Проверить цель"
            taskPlanner.database -> taskPlanner.goalService "Возвращает цель"
            taskPlanner.goalService -> taskPlanner.taskService "Подтверждение"
            taskPlanner.taskService -> taskPlanner.database "Запросить задачи"
            taskPlanner.database -> taskPlanner.taskService "Возвращает список"
            taskPlanner.taskService -> taskPlanner.apiGateway "Возвращает задачи"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        dynamic taskPlanner "UseCase8" "Изменение статуса задачи в цели" {
            autoLayout
            user -> taskPlanner.apiGateway "PUT /api/goals/{goalId}/tasks/{taskId}/status"
            taskPlanner.apiGateway -> taskPlanner.taskService "Обновить статус"
            taskPlanner.taskService -> taskPlanner.goalService "Проверить цель"
            taskPlanner.goalService -> taskPlanner.database "Проверить цель"
            taskPlanner.database -> taskPlanner.goalService "Возвращает цель"
            taskPlanner.goalService -> taskPlanner.taskService "Подтверждение"
            taskPlanner.taskService -> taskPlanner.database "Обновить статус"
            taskPlanner.database -> taskPlanner.taskService "Подтверждение"
            taskPlanner.taskService -> taskPlanner.apiGateway "Возвращает задачу"
            taskPlanner.apiGateway -> user "Возвращает результат"
        }

        styles {
            element "database" {
                shape cylinder
            }
            element "person" {
                shape person
            }
        }
    }
}
