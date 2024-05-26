﻿#Область License

//MIT License

//Copyright (c) 2024 Dmitrii Sidorenko

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Основная функция обработки запроса.
//  На основе запроса формируем структуру и отдаем в обработку метода.
//
// Параметры:
//  Запрос - HTTPСервисЗапрос - Запрос http сервиса  	
// 
// Возвращаемое значение:
//   Ответ - HTTPСервисОтвет - ответ на запрос 
//
Функция ПолучитьОтветНаЗапрос(Знач Запрос) Экспорт
	
	// Подготавливаем структуру из запроса
	СтруктураВходныхПараметров = Новый Структура;
	
// Данные для поиска Метода в Справочнике.PAPI_Методы++	
	// Получаем имя метода
	перИмяМетода  = Запрос.ПараметрыURL["MethodName"]; 
	
	// Помещаем имя метода в структуру
	Если перИмяМетода <> Неопределено Тогда 		
		СтруктураВходныхПараметров.Вставить("ИмяМетода", перИмяМетода);
	Иначе
		
		// Метод не заполнен
		Возврат	PAPI_РаботаСОтветом.ЗаполнитьОтветПоКодуСообщения("Err1");
		
	КонецЕсли;
	
	// Получаем версию метода
	перВерсияМетода  = Запрос.ПараметрыURL["MethodVersion"];    
	// Помещаем имя метода в структуру
	Если перВерсияМетода <> Неопределено Тогда
		СтруктураВходныхПараметров.Вставить("ВерсияМетода", перВерсияМетода);
	Иначе
		
		// Версия не заполнена
		Возврат PAPI_РаботаСОтветом.ЗаполнитьОтветПоКодуСообщения("Err2");
		
	КонецЕсли;	
// Данные для поиска Метода в Справочнике.PAPI_Методы--	

	// Запрос.Заголовки - Содержит заголовки HTTP-запроса.
	перЗаголовкиЗапроса = Новый Массив;
	Для каждого Заголовок Из Запрос.Заголовки Цикл
		перЗаголовкиЗапроса.Добавить(Новый Структура("Имя, Значение", Заголовок.Ключ, Заголовок.Значение));
	КонецЦикла;
	СтруктураВходныхПараметров.Вставить("ЗаголовкиЗапроса",перЗаголовкиЗапроса);

	
	// Получаем метод запроса (Доступные методы заданы Справочники.PAPI_Методы.МассивВсехМетодов)
	СтруктураВходныхПараметров.Вставить("МетодЗапроса", Запрос.HTTPМетод);
		
	// Ищем метод и добавляем его в структуру параметров
	// PAPI_РаботаСМетодами.ПоискИДобавлениеМетодаPAPIВСтруктуру(СтруктураВходныхПараметров);
	текМетод = PAPI_РаботаСМетодами.ПоискМетодаPAPI(СтруктураВходныхПараметров);

	// Получаем структуру метода (Если в метод добавляем реквизит, незабываем его добавить и сюда)
	// СтруктураМетода = PAPI_РаботаСМетодами.НайтиМетодИСформироватьСтруктуру(СтруктураВходныхПараметров);
	
	// Если метод отсутствует, значит метод не найден
	Если Не ЗначениеЗаполнено(текМетод) Тогда
		
		Возврат PAPI_РаботаСОтветом.ЗаполнитьОтветПоКодуСообщения("Err3");

	Иначе
		Если Не текМетод.Разрешен Тогда
			
			// Запись в РегистрСведений.PAPI_ЛогМетодов
			Если текМетод.ЛогироватьМетод Тогда
				
				СтруктураОшибки = PAPI_РаботаСОтветом.ПолучитьОтветОшибкуПоКодуИЯзыку("Err4");			
				PAPI_Логирование.ЗаписатьВЛогМетодов(ТекущаяДатаСеанса(), текМетод, Перечисления.PAPI_ТипЛога.Ошибка, СтруктураОшибки.ТекстОшибки);

			КонецЕсли;  
							
			Возврат PAPI_РаботаСОтветом.ЗаполнитьОтветПоКодуСообщения("Err4");

		КонецЕсли;	
	КонецЕсли;	
		
	// Базовая часть URL-запроса
	СтруктураВходныхПараметров.Вставить("БазовыйURL", Запрос.БазовыйURL);
	
	// Относительный URL-запроса
	СтруктураВходныхПараметров.Вставить("ОтносительныйURL", Запрос.ОтносительныйURL);
 
	// Забираем параметры из запроса
	перПараметрыЗапроса = Новый Структура;
	Для Каждого Параметр Из Запрос.ПараметрыЗапроса Цикл
		
		перПараметрыЗапроса.Вставить(СокрЛП(Параметр.Ключ), Параметр.Значение);
		
	КонецЦикла;        
	
	СтруктураВходныхПараметров.Вставить("ПараметрыЗапроса", перПараметрыЗапроса);
	
	// Тело запроса
	Если СтруктураВходныхПараметров.МетодЗапроса = "GET"
		ИЛИ СтруктураВходныхПараметров.МетодЗапроса = "TRACE" Тогда 
		
		// GET и TRACE с телом не работаем!
		
	Иначе	 
		Если текМетод.ТелоЗапроса = Перечисления.PAPI_ТелоЗапроса.Строка Тогда 
			
			перТелоЗапроса = Запрос.ПолучитьТелоКакСтроку();
			
		ИначеЕсли текМетод.ТелоЗапроса = Перечисления.PAPI_ТелоЗапроса.Поток Тогда
			
			// TODO: Надо протестировать, пока поставил заглушку
			перТелоЗапроса = Запрос.ПолучитьТелоКакПоток();
				
		ИначеЕсли текМетод.ТелоЗапроса = Перечисления.PAPI_ТелоЗапроса.ДвоичныеДанные Тогда
			
			// TODO: Надо протестировать, пока поставил заглушку
			перТелоЗапроса = Запрос.ПолучитьТелоКакДвоичныеДанные();
			
		Иначе
			
			ТекстОшибки = НСтр("ru = 'Неизвестное тело запроса';
								|en = 'Unknown request body'");
			
			PAPI_Логирование.ЗаписатьВЛог("PAPI.Методы", Перечисления.PAPI_ТипЛога.Предупреждение, ТекстОшибки, текМетод);
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Записываем запрос, для отладки++
	Если текМетод.ЛогироватьЗапрос Тогда 
		
		PAPI_Логирование.ЗаписатьВходящийЗапрос(текМетод, перТелоЗапроса, СтруктураВходныхПараметров);

	КонецЕсли;
	// Записываем запрос, для отладки--
	
	Если перТелоЗапроса <> Неопределено Тогда 
		
		СтруктураВходныхПараметров.Вставить("ТелоЗапроса", перТелоЗапроса);
		
	КонецЕсли;
	

	Ответ = PAPI_РаботаСМетодами.ПолучитьОтветМетода(СтруктураВходныхПараметров, текМетод); 
	
	Возврат Ответ;
	
КонецФункции	

#КонецОбласти