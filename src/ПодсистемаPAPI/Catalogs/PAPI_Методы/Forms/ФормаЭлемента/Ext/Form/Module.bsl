﻿#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)	
	
// TODO: Протестировать и снять заглушку тут и в ВидимостьНаСтраницеВычисления()	
// Заглушка++	
	Если Объект.ТелоЗапроса <> Перечисления.PAPI_ТелоЗапроса.Строка Тогда 
		Объект.ТелоЗапроса = Перечисления.PAPI_ТелоЗапроса.Строка;	
	КонецЕсли; 
// Заглушка--	
	Если Не ЗначениеЗаполнено(Объект.ТелоОтвета) Тогда 
		Объект.ТелоОтвета = Перечисления.PAPI_ТелоОтвета.Строка;	
	КонецЕсли;
	
	Если Не Объект.Ссылка.Пустая() Тогда 
		
		ТЗВыбранныхМетодов = Объект.HTTPМетоды;
		
	Иначе
	// Создан копированием++
		Если ЗначениеЗаполнено(Параметры.ЗначениеКопирования)
			И ТипЗнч(Параметры.ЗначениеКопирования) = Тип("СправочникСсылка.PAPI_Методы") Тогда	
				
			ПриЧтенииНаСервере(Параметры.ЗначениеКопирования);
			ТЗВыбранныхМетодов = Параметры.ЗначениеКопирования.HTTPМетоды;	
			
		КонецЕсли;
	// Создан копированием--	
	КонецЕсли;
	
	// Заполняем выбранные ранее методы++
	ВТЗ = Новый ТаблицаЗначений;
	ВТЗ.Колонки.Добавить("Доступен");
	ВТЗ.Колонки.Добавить("Метод");

	Для Каждого СтрокаТЗ Из Объект.HTTPМетоды Цикл 
		новСтрока 			= ВТЗ.Добавить();
		новСтрока.Метод 	= СтрокаТЗ.HTTPМетод;
		новСтрока.Доступен	= 1;
	КонецЦикла;	
	// Заполняем выбранные ранее методы--
	
	МассивМетодов = Справочники.PAPI_Методы.МассивВсехМетодов();
	Для Каждого элМассива Из МассивМетодов Цикл 
		новСтрока 			= ВТЗ.Добавить();
		новСтрока.Метод 	= элМассива;
		новСтрока.Доступен	= 0;
	КонецЦикла;
	ВТЗ.Свернуть("Метод","Доступен");
	ДоступныеМетоды.Загрузить(ВТЗ);

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ) 
	
	ПриОткрытииНаСервере(); 
	
КонецПроцедуры

&НаСервере
Процедура ПриОткрытииНаСервере() 
	
	ВидимостьНаСтраницеВычисления();  
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи) 
	
	Если Объект.Ссылка.Пустая() Или Модифицированность Тогда 
		ЗаполнитьHTTPМетоды(ТекущийОбъект);	
		ПоместитьМетодВНастройки(ТекущийОбъект);
	КонецЕсли;  
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьHTTPМетоды(ТекущийОбъект) 
	
	ТекущийОбъект.HTTPМетоды.Очистить();
	
	Для Каждого СтрокаТЗ Из ДоступныеМетоды Цикл
		
		Если СтрокаТЗ.Доступен Тогда
			
			новСтрока         	= ТекущийОбъект.HTTPМетоды.Добавить();
			новСтрока.HTTPМетод = СтрокаТЗ.Метод;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры	

&НаСервере
Процедура ПоместитьМетодВНастройки(ТекущийОбъект)
	      
	СтруктураДанных = Новый Структура;
// СтруктураВычисления ++	
	СтруктураВычисления = Новый Структура;
	СтруктураВычисления.Вставить("КодОбработкиТелаЗапроса",		КодОбработкиТелаЗапроса);	
	СтруктураВычисления.Вставить("КодПроизвольногоАлгоритма",	КодПроизвольногоАлгоритма);
	СтруктураВычисления.Вставить("ПараметрыЗапроса",			ПараметрыЗапроса.Выгрузить(,"Имя,Алгоритм"));

	СтруктураДанных.Вставить("СтруктураВычисления",СтруктураВычисления);
// СтруктураВычисления --

	ДанныеXML = PAPI_ОбщегоНазначенияВызовСервера.СериализаторXML(СтруктураДанных);
	ТекущийОбъект.Настройки = Новый ХранилищеЗначения(?(ДанныеXML.Отработал,ДанныеXML.Результат,""));
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Если Не ТекущийОбъект.ЭтоГруппа Тогда

		СтруктураНастройки = PAPI_РаботаСМетодами.СтруктураНастроекМетода(ТекущийОбъект.Настройки);

		Если СтруктураНастройки.Свойство("СВ_КодОбработкиТелаЗапроса") Тогда
			КодОбработкиТелаЗапроса = СтруктураНастройки.СВ_КодОбработкиТелаЗапроса;	
		КонецЕсли;	
		
		Если СтруктураНастройки.Свойство("СВ_КодПроизвольногоАлгоритма") Тогда
			КодПроизвольногоАлгоритма = СтруктураНастройки.СВ_КодПроизвольногоАлгоритма;	
		КонецЕсли;	
		
		Если СтруктураНастройки.Свойство("СВ_ПараметрыЗапроса") Тогда
			ПараметрыЗапроса.Загрузить(СтруктураНастройки.СВ_ПараметрыЗапроса);	
		КонецЕсли;	
		
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДоступныеМетоды  

&НаКлиенте
Процедура ДоступныеМетодыДоступенПриИзменении(Элемент)
	
	УстановитьМодифицированность();  
	
КонецПроцедуры

&НаКлиенте
Процедура ПроизвольныйАлгоритмПриИзменении(Элемент)   
	
	ПроизвольныйАлгоритмПриИзмененииНаСервере(); 
	
КонецПроцедуры 

#КонецОбласти

#Область ОбработчикиСобытийЭлементовГруппыСтраницы

#Область Страница_ПараметрыЗапроса
&НаКлиенте
Процедура ПараметрыЗапросаПриИзменении(Элемент)
	
	УстановитьМодифицированность();	 
	
КонецПроцедуры  

&НаКлиенте
Процедура ПараметрыЗапросаПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.ПараметрыЗапроса.ТекущиеДанные;	
	Элементы.ТекущийПроизвольныйКод.Видимость = (ТекущиеДанные <> Неопределено И ТипЗнч(ТекущиеДанные.Алгоритм) = Тип("Строка"));  
	
	Если Элементы.ТекущийПроизвольныйКод.Видимость Тогда 
		ТекущийПроизвольныйКод = ТекущиеДанные.Алгоритм;
	КонецЕсли;	
	
КонецПроцедуры


&НаКлиенте
Процедура ТекущийПроизвольныйКодПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ПараметрыЗапроса.ТекущиеДанные;
	Элементы.ТекущийПроизвольныйКод.Видимость = (ТекущиеДанные <> Неопределено И ТипЗнч(ТекущиеДанные.Алгоритм) = Тип("Строка"));
	
	Если Элементы.ТекущийПроизвольныйКод.Видимость Тогда 
		ТекущиеДанные.Алгоритм = ТекущийПроизвольныйКод;
		УстановитьМодифицированность();
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ПараметрыЗапросаАлгоритмПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ПараметрыЗапроса.ТекущиеДанные;
    Элементы.ТекущийПроизвольныйКод.Видимость = (ТекущиеДанные <> Неопределено И ТипЗнч(ТекущиеДанные.Алгоритм) = Тип("Строка"));
	
    Если Элементы.ТекущийПроизвольныйКод.Видимость Тогда 
		
		ТекущийПроизвольныйКод = ТекущиеДанные.Алгоритм;  
		
	Иначе
		ТекущийПроизвольныйКод = "";
	КонецЕсли; 
	
КонецПроцедуры


#КонецОбласти

#Область Страница_Вычисления
&НаСервере
Процедура ПроизвольныйАлгоритмПриИзмененииНаСервере()
	
	ВидимостьНаСтраницеВычисления();
	
КонецПроцедуры

&НаСервере
Процедура ВидимостьНаСтраницеВычисления()
	
	Если Объект.ПроизвольныйАлгоритм Тогда 
		Элементы.Алгоритм.Видимость = Ложь;
		Элементы.КодПроизвольногоАлгоритма.ТолькоПросмотр = Ложь;
	Иначе
		Элементы.Алгоритм.Видимость = Истина;
		Элементы.КодПроизвольногоАлгоритма.ТолькоПросмотр = Истина;	
	КонецЕсли;	
	
// TODO: Протестировать и снять заглушку		
// Заглушка++	
	Элементы.ТелоЗапроса.Доступность = Ложь;	
	//Элементы.ТелоОтвета.Доступность = Ложь;	
// Заглушка--
	
КонецПроцедуры

&НаКлиенте
Процедура КодВходящихДанныхПриИзменении(Элемент)
	
	УстановитьМодифицированность();
	
КонецПроцедуры 

&НаКлиенте
Процедура КодПроизвольногоАлгоритмаПриИзменении(Элемент)

	УстановитьМодифицированность();
		
КонецПроцедуры


#КонецОбласти

#Область КонсольКода

&НаКлиенте
Процедура КодОбработкиТелаЗапросаОткрытие(Элемент, СтандартнаяОбработка)
	ОткрытьФормуРедактированияКода(Элемент, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура КодПроизвольногоАлгоритмаОткрытие(Элемент, СтандартнаяОбработка)
	ОткрытьФормуРедактированияКода(Элемент, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Функция ОткрытьФормуРедактированияКода(Элемент, СтандартнаяОбработка, ПользовательскиеОбъектыПодсказки = Неопределено)
	СтандартнаяОбработка = Ложь;
	ПарамОткрытия = Новый Структура;
	ПарамОткрытия.Вставить("Заголовок", Элемент.Заголовок);
	ПарамОткрытия.Вставить("ТекстАлгоритма", Элемент.ТекстРедактирования);	
	
	ПарамОткрытия.Вставить("ПользовательскиеОбъекты", ПользовательскиеОбъектыПодсказки);
	
	ОткрытьФорму("Обработка.PAPI_КонсольКода.Форма.Форма", 
			ПарамОткрытия, 
			ЭтотОбъект, 
			, 
			, 
			, 
			Новый ОписаниеОповещения("ОкончаниеРедактированиеКода", ЭтотОбъект, Элемент.Имя), 
			РежимОткрытияОкнаФормы.БлокироватьОкноВладельца
	);
КонецФункции

&НаКлиенте
Процедура ОкончаниеРедактированиеКода(Результат, ДопПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЭтотОбъект[ДопПараметры] = Результат;
	Модифицированность = Истина;
КонецПроцедуры

#КонецОбласти

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьМодифицированность()

	Если Не Модифицированность Тогда 
		Модифицированность = Истина;
	КонецЕсли;	
	
КонецПроцедуры	

#КонецОбласти



