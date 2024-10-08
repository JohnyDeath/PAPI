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

// TODO: Остатки от PAPI 2019 года. Посмотреть надо ли и привести в порядок.
// ТекстФоновойПроцедуры = "
// |//Тут передаем текст фоновой процедуры, это может быть вызов каких то процедур или полноценный код
// |//вызов процедур проще, т.к. тупо легче отлаживать, т.к. код в этой процедуре обычной отладке не поддастся,
// |//а при вызове процедуры или функции мы ставим там точку останова и включаем в отладке автоматическое
// |//подключение  фоновых заданий. Запускать можно любые методы для выполнения на сервере.
// |
// |ОбщийМодульСервер.ВыполнитьНужнуюЗадачу(Параметр1,Параметр2);"
// И вызывать ее выполнение:
//	ЗапуститьФоновоеВыполнение(ТекстФоновойПроцедуры,Новый Структура("Параметр1,Параметр2",Параметр1,Параметр2));
//
// Функция ЗапуститьФоновоеВыполнение(ТекстПроцедуры,СтруктураПараметров=Неопределено) Экспорт
//    УникальныйИдентификатор = Новый УникальныйИдентификатор;
//    ПараметрыВыполнения = Новый Массив;
//    ПараметрыВыполнения.Добавить(ТекстПроцедуры);
//    ПараметрыВыполнения.Добавить(СтруктураПараметров);
//    
//    ФоновыеЗадания.Выполнить("PAPI_АсинхронныеОперации.УниверсальноеФЗ",ПараметрыВыполнения,УникальныйИдентификатор);
//    Возврат УникальныйИдентификатор;
// КонецФункции
//Процедура УниверсальноеФЗ(ТекстМодуля,ПараметрыВыполнения) Экспорт
//	ПолныйТекстМодуля = "";
//	Для Каждого ТекПараметр Из ПараметрыВыполнения Цикл
//		ПолныйТекстМодуля = ПолныйТекстМодуля+ТекПараметр.Ключ+"=ПараметрыВыполнения."+ТекПараметр.Ключ+";"+Символы.ПС;
//	КонецЦикла;
//	ПолныйТекстМодуля = ПолныйТекстМодуля + ТекстМодуля;
//	Выполнить(ПолныйТекстМодуля);
//КонецПроцедуры


// Выполнение алгоритма в регистре очередей 
//
// Параметры:
//  ПараметрыРегистра	 - Структура
//		Алгоритм			- СправочникСсылка.PAPI_Алгоритмы 		(Обязательный параметр)
//		КлючПоиска			- Строка - Ключ для поиска результата  	(Обязательный параметр) 
//		ПараметрыАлгоритма	- Структура - Параметры передаваемые в алгоритм   
//		Выполнен			- Булево - Признак того, что алгоритм выполнен или нет
//		Ошибка				- Булево - Признак того, что при выполнении была ошибка
//		ТекстОшибки			- Строка - Описание произошедшей ошибки в ходе выполнения алгоритма 
//		ДатаНачала			- Дата - время начала выполнения алгоритма в фоновом задании
//		ДатаОкончания 		- Дата - время окончания выполнения алгоритма в фоновом задании
//		КоличествоПопыток 	- Число - количество попыток приводивших к ошибке 
//
Процедура ВыполнитьАлгоритмИзОчередиАлгоритмов(ПараметрыРегистра) Экспорт
	
	ВключенПривилегированныйРежим = Ложь;
	Если Не ПривилегированныйРежим() Тогда  
		ВключенПривилегированныйРежим = Истина;
		УстановитьПривилегированныйРежим(ВключенПривилегированныйРежим);
	КонецЕсли;	
	
	ПроверкаПройдена = Истина; 
	
	Если ТипЗнч(ПараметрыРегистра) = Тип("Структура") Тогда 
		
	    ПараметрыРегистра.Вставить("ДатаНачала", ТекущаяДатаСеанса());

		ТекстОшибки = "";
		
		Если Не ПараметрыРегистра.Свойство("Алгоритм") Тогда 
			
			ПроверкаПройдена = Ложь; 	
			ТекстОшибки = ТекстОшибки + ?(ПустаяСтрока(ТекстОшибки), "", Символы.ПС) + "Отсутствует Алгоритм";
			
		Иначе
			Если ТипЗнч(ПараметрыРегистра.Алгоритм) = Тип("Строка") Тогда
					
				ПараметрыРегистра.Алгоритм = PAPI_РаботаСАлгоритмами.ПолучитьАлгоритмПоИмени(ПараметрыРегистра.Алгоритм); 
					
			КонецЕсли;
	
			Если ТипЗнч(ПараметрыРегистра.Алгоритм) <> Тип("СправочникСсылка.PAPI_Алгоритмы") Тогда 
				
				ПроверкаПройдена = Ложь; 	
				ТекстОшибки = ТекстОшибки + ?(ПустаяСтрока(ТекстОшибки), "", Символы.ПС) + "Отсутствует Алгоритм";
				
			КонецЕсли;
			
		КонецЕсли;	  
		
		
		Если Не ПараметрыРегистра.Свойство("КлючПоиска") Тогда 
			
			ПроверкаПройдена = Ложь;
			ТекстОшибки = ТекстОшибки + ?(ПустаяСтрока(ТекстОшибки), "", Символы.ПС) + "Отсутствует КлючПоиска";

		КонецЕсли;	
		
		Если ПараметрыРегистра.Свойство("ПараметрыАлгоритма")
			И ТипЗнч(ПараметрыРегистра.ПараметрыАлгоритма) = Тип("Структура") Тогда
			
			ПараметрыАлгоритма = ПараметрыРегистра.ПараметрыАлгоритма;  
			
		Иначе 
			
			ПараметрыАлгоритма = Новый Структура; 
			
		КонецЕсли;
		
	
		Если ПроверкаПройдена Тогда
							
			СтруктураВозврата = PAPI_РаботаСАлгоритмами.РешитьАлгоритм(ПараметрыРегистра.Алгоритм, ПараметрыАлгоритма);   
			
			Если СтруктураВозврата.Отработал Тогда         
					
				PAPI_Логирование.ЗаписатьВЛог("PAPI.Информация", Перечисления.PAPI_ТипЛога.Информация, 
					"Выполнен алгоритм :" + ПараметрыРегистра.Алгоритм.ИмяАлгоритма, "PAPI_АсинхронныеОперации.ВыполнитьАлгоритмИзОчередиАлгоритмов");
					
			Иначе
				
				ТекстОшибки = ТекстОшибки + ?(ПустаяСтрока(ТекстОшибки), "", Символы.ПС) 
					+ "Ошибка выполнения алгоритма: " + ПараметрыРегистра.Алгоритм.ИмяАлгоритма + СтруктураВозврата.ТекстОшибки;
							
				PAPI_Логирование.ЗаписатьВЛог("PAPI.Ошибка", Перечисления.PAPI_ТипЛога.Ошибка, ТекстОшибки, 
					"PAPI_АсинхронныеОперации.ВыполнитьАлгоритмИзОчередиАлгоритмов");			
								
			КонецЕсли;
			
			ПараметрыРегистра.Вставить("ДатаОкончания",	ТекущаяДатаСеанса());	
			ПараметрыРегистра.Вставить("Выполнен",		СтруктураВозврата.Отработал);
			ПараметрыРегистра.Вставить("Ошибка",	 	Не СтруктураВозврата.Отработал);
            ПараметрыРегистра.Вставить("ТекстОшибки",	ТекстОшибки);

			
			// Записываем в регистр информацию по выполнению
		    РегистрыСведений.PAPI_ОчередьАлгоритмовДляФоновогоВыполнения.ДобавитьИзменитьЗапись(ПараметрыРегистра);
		
		Иначе
		
			PAPI_Логирование.ЗаписатьВЛог("PAPI.Ошибка", Перечисления.PAPI_ТипЛога.Ошибка, ТекстОшибки, 
				"PAPI_АсинхронныеОперации.ВыполнитьАлгоритмИзОчередиАлгоритмов");		
				
		КонецЕсли;	
	Иначе  
			
		ТекстОшибки = НСтр("ru = 'Запись не является Структурой'; en = 'Record is not a Structure'");		
		PAPI_Логирование.ЗаписатьВЛог("PAPI.Ошибка", Перечисления.PAPI_ТипЛога.Ошибка, ТекстОшибки, "PAPI_АсинхронныеОперации.ВыполнитьАлгоритмИзОчередиАлгоритмов");
			
	КонецЕсли;   
		
		
	Если ВключенПривилегированныйРежим Тогда 
		ВключенПривилегированныйРежим = Ложь;
		УстановитьПривилегированныйРежим(ВключенПривилегированныйРежим);	
	КонецЕсли;
	
КонецПроцедуры	     




#Область ФоновыеЗадания
// Регламентное задание "PAPI_ВыполнитьОбработкуОчередиДействийСДокументами"
Процедура ВыполнитьОбработкуОчередиДействийСДокументами() Экспорт 

	ВключенПривилегированныйРежим = Ложь;
	Если Не ПривилегированныйРежим() Тогда  
		ВключенПривилегированныйРежим = Истина;
		УстановитьПривилегированныйРежим(ВключенПривилегированныйРежим);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	PAPI_ОчередьДействийСДокументами.ТипОбъекта КАК ТипОбъекта,
		|	PAPI_ОчередьДействийСДокументами.ИдОбъекта КАК ИдОбъекта,
		|	PAPI_ОчередьДействийСДокументами.Действие КАК Действие,
		|	PAPI_ОчередьДействийСДокументами.Представление КАК Представление,
		|	PAPI_ОчередьДействийСДокументами.Выполнено КАК Выполнено,
		|	PAPI_ОчередьДействийСДокументами.ТекстОшибки КАК ТекстОшибки,
		|	PAPI_ОчередьДействийСДокументами.КоличествоПопыток КАК КоличествоПопыток
		|ИЗ
		|	РегистрСведений.PAPI_ОчередьДействийСДокументами КАК PAPI_ОчередьДействийСДокументами
		|ГДЕ
		|	НЕ PAPI_ОчередьДействийСДокументами.Выполнено
		|";
	
	перКоличествоПопыток = PAPI_ОбщегоНазначенияВызовСервера.ПрочитатьЗначениеКонстанты("PAPI_КоличествоПопытокОчередиДокументов");
	Если ЗначениеЗаполнено(перКоличествоПопыток) Тогда 
		Запрос.Текст = Запрос.Текст + "	И PAPI_ОчередьДействийСДокументами.КоличествоПопыток < &КоличествоПопыток";
		Запрос.УстановитьПараметр("КоличествоПопыток", перКоличествоПопыток);
	КонецЕсли;	
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		СтруктураРегистра = РегистрыСведений.PAPI_ОчередьДействийСДокументами.ПолучитьСтруктуруПоУмолчанию();  
		ЗаполнитьЗначенияСвойств(СтруктураРегистра, ВыборкаДетальныеЗаписи);

		РегистрыСведений.PAPI_ОчередьДействийСДокументами.ВыполнитьДействие(СтруктураРегистра);
		
	КонецЦикла;
	
	Если ВключенПривилегированныйРежим Тогда 
		ВключенПривилегированныйРежим = Ложь;
		УстановитьПривилегированныйРежим(ВключенПривилегированныйРежим);	
	КонецЕсли;
		
КонецПроцедуры

#КонецОбласти