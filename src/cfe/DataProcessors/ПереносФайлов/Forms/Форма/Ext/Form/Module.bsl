﻿

&Вместо("ПеренестиМеждуТомами")
Процедура sd_ПеренестиМеждуТомами(ФайлОбъект, СвойстваТома)
	СвойстваФайла = РаботаСФайламиВТомахСлужебный.СвойстваФайлаВТоме();
	ЗаполнитьЗначенияСвойств(СвойстваФайла, ФайлОбъект);
	Если ТипЗнч(ФайлОбъект) = Тип("СправочникОбъект.ВерсииФайлов") Тогда
		СвойстваФайла.ВладелецФайла = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
		ФайлОбъект.Владелец, "ВладелецФайла");
	КонецЕсли;
	
	ТекущийПутьКФайлу = РаботаСФайламиВТомахСлужебный.ПолноеИмяФайлаВТоме(СвойстваФайла);
	
	ФайлНаДиске = Новый Файл(ТекущийПутьКФайлу);
	Если Не ФайлНаДиске.Существует() Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Файл ""%1"" не найден.'"), ТекущийПутьКФайлу);
	КонецЕсли;
	
	СвойстваФайла.Том = ТомХраненияПриемник;
		
	//++Frog 10.03.2022
	ФайлОбъект.Том = ТомХраненияПриемник;
	Если ТомХраненияПриемник.sd_МестоХраненияФайлов = Перечисления.sd_МестоХраненияФайлов.ЛокальноеХранилище Тогда  
		СвойстваФайла.ПутьКФайлу = "";	
		НовыйПутьКФайлу = РаботаСФайламиВТомахСлужебный.ПолноеИмяФайлаВТоме(СвойстваФайла, ФайлОбъект.ДатаМодификацииУниверсальная);

		КопироватьФайл(ТекущийПутьКФайлу, НовыйПутьКФайлу);
		ФайлОбъект.ПутьКФайлу = Сред(НовыйПутьКФайлу, СтрДлина(СвойстваТома.ПутьКТому) + 1);
	ИначеЕсли ТомХраненияПриемник.sd_МестоХраненияФайлов = Перечисления.sd_МестоХраненияФайлов.ХранилищеS3Minio Тогда
		НовыйПутьКФайлу = ?(Лев(СвойстваФайла.ПутьКФайлу,1)="\",СвойстваФайла.ПутьКФайлу,"\"+СвойстваФайла.ПутьКФайлу);
		СвойстваФайла.ПутьКФайлу = "";	
		
		ДвоичныеДанныеИлиПуть = Новый ДвоичныеДанные(ТекущийПутьКФайлу);
		ПараметрыMinio = MinioS3Connector.ПараметрыMinio();
		
		ПараметрыMinio.РаботаВДиалоге = Ложь;
		ПараметрыMinio.НастройкиMinio = ТомХраненияПриемник.sd_ВнешнийИсточникХраненияФайлов;		
		ПараметрыMinio.ДвоичныеДанные = ДвоичныеДанныеИлиПуть;								
		ПараметрыMinio.ПутьКФайлу = НовыйПутьКФайлу;

		//Если при записи произойдет ошибка, то она упадет в исключение ниже.
		MinioS3Connector.СохранитьФайлВMinio(ПараметрыMinio);
		//Если исключения нет, значит все записалось и в переменной ПараметрыMinio.ПутьКФайлу ссылка на записанный файл в Minio
		ФайлОбъект.ПутьКФайлу = ПараметрыMinio.ПутьКФайлу;
	Иначе 
		СообщениеОбОшибке = НСтр("ru = 'Выбранное в томе значение места хранения файлов не описано в алгоритме'");
		ВызватьИсключение(СообщениеОбОшибке);
	КонецЕсли;
	
	//++Frog 10.03.2022	
	
	ФайлОбъект.Записать();
	
	РаботаСФайламиВТомахСлужебный.УдалитьФайл(ТекущийПутьКФайлу);
КонецПроцедуры   

&Вместо("ПеренестиВТома")
Процедура sd_ПеренестиВТома(ФайлОбъект, СвойстваТома)
	ДанныеФайла = РаботаСФайлами.ДвоичныеДанныеФайла(ФайлОбъект.Ссылка);
	ФайлОбъект.ТипХраненияФайла = Перечисления.ТипыХраненияФайлов.ВТомахНаДиске;
	
	//++Frog 16.03.2022
	Если ТомХраненияПриемник.sd_МестоХраненияФайлов = Перечисления.sd_МестоХраненияФайлов.ЛокальноеХранилище Тогда
		РаботаСФайламиВТомахСлужебный.ДобавитьФайл(ФайлОбъект, ДанныеФайла,
			ФайлОбъект.ДатаМодификацииУниверсальная, , ?(ПереноситьВТом, ТомХраненияПриемник, Неопределено));
	ИначеЕсли ТомХраненияПриемник.sd_МестоХраненияФайлов = Перечисления.sd_МестоХраненияФайлов.ХранилищеS3Minio Тогда
		Если ФайлОбъект.Владелец <> Неопределено Тогда	
			СвойстваФайла = РаботаСФайламиВТомахСлужебный.СвойстваФайлаВТоме();
			ЗаполнитьЗначенияСвойств(СвойстваФайла, ФайлОбъект);	    
			СвойстваФайла.Том = ТомХраненияПриемник;
			СвойстваФайла.ВладелецФайла = ФайлОбъект.Владелец.ВладелецФайла;
			ПутьКФайлу = РаботаСФайламиВТомахСлужебный.ПолноеИмяФайлаВТоме(СвойстваФайла);
			
			ПараметрыMinio = MinioS3Connector.ПараметрыMinio();                           	
			ПараметрыMinio.РаботаВДиалоге = Ложь;
			ПараметрыMinio.НастройкиMinio = ТомХраненияПриемник.sd_ВнешнийИсточникХраненияФайлов;		
			ПараметрыMinio.ДвоичныеДанные = ДанныеФайла;								
			ПараметрыMinio.ПутьКФайлу = ПутьКФайлу;

			//Если при записи произойдет ошибка, то она упадет в исключение ниже.
			MinioS3Connector.СохранитьФайлВMinio(ПараметрыMinio);
			//Дозаполняем необходимые реквизиты
			ФайлОбъект.ПутьКФайлу = ПараметрыMinio.ПутьКФайлу;                                                                     
			ФайлОбъект.Том = ТомХраненияПриемник;
		Иначе
			СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Для данного типа хранения файла 1% алгоритм не реализован'"), Строка(ТипЗнч(ФайлОбъект.ВладелецФайла)));
			
			ВызватьИсключение(СообщениеОбОшибке);
		КонецЕсли;
	Иначе 
		СообщениеОбОшибке = НСтр("ru = 'Выбранное в томе значение места хранения файлов не описано в алгоритме'");
		ВызватьИсключение(СообщениеОбОшибке);
	КонецЕсли;
	
	//--Frog 16.03.2022		
	Если ФайлОбъект.ТипХраненияФайла <> Перечисления.ТипыХраненияФайлов.ВИнформационнойБазе Тогда
		РаботаСФайламиСлужебный.УдалитьЗаписьИзРегистраДвоичныеДанныеФайлов(ФайлОбъект.Ссылка);	
	КонецЕсли;
	
	ФайлОбъект.Записать();
КонецПроцедуры


