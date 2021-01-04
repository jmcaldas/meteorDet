function capturaBolido(vid,framerate,numframes,thrN,thrDiff,tCalibracion,brillo,contraste,calidadAVI,tamano)

data = getdata(vid,10);
dif = imsubtract(data(:,:,:,10),data(:,:,:,1));
dif = dif(dif>0);
N = size(find(dif>thrDiff),1);

if N > thrN %Evento detectado
    
    t = clock();
    [buff,time] = getdata(vid,numframes);
    d = date;
    stop(vid);
    flushdata(vid);
    
    for i=1:numframes
        frames2(:,:,:,i) = imresize(buff(:,:,:,i),[tamano(2) tamano(1)]);
    end
    
    clear buff
    
    %Guardar Evento
    
    nombreArchivo = strcat('Evento-',d,'-',num2str(t(4)),'-',num2str(t(5)),'-',num2str(floor(t(6))),'.avi');
    writerObj = VideoWriter(nombreArchivo,'Motion JPEG AVI');
    p=polyfit(linspace(1,length(time),length(time)),time',1);
    writerObj.FrameRate = 1/p(1);
    writerObj.Quality = calidadAVI;
    open(writerObj);
    
    for ii = 1:size(frames2,4);
        writeVideo(writerObj,frames2(:,:,:,ii));
    end
    
    close(writerObj);
    nombreArchivo = strcat('Evento-',d,'-',num2str(t(4)),'-',num2str(t(5)),'-',num2str(floor(t(6))),'.txt');
    fileID = fopen(nombreArchivo,'w');
    for i = 1:length(time)
        fprintf(fileID,'%f\n',time(i));
    end
    fclose(fileID);
    
    clear time buff 
    %%%%%CALIBRACION%%%%%
    
    t = clock();
    d = date;
    nombreArchivo = strcat('Calibracion-',d,'-',num2str(t(4)),'-',num2str(t(5)),'-',num2str(floor(t(6))),'.avi');
    
    logfile=avifile(nombreArchivo,'Quality',calidadAVI,'FPS',framerate);
    
    vid.LoggingMode = 'disk';
    vid.DiskLogger = logfile;
    set(vid,'ReturnedColorspace','grayscale');
    set(vid,'FramesPerTrigger',round(tCalibracion*framerate)); %1 minuto
    set(vid,'TriggerRepeat',0);
    set(getselectedsource(vid),'Brightness',brillo);
    set(getselectedsource(vid),'Contrast',contraste);
    
    start(vid);
    while (vid.DiskLoggerFrameCount<vid.FramesPerTrigger)
    end
    logfile = close(vid.DiskLogger);
    stop(vid);
    
    vid.LoggingMode = 'memory';
    vid.FramesPerTrigger = 10;
    vid.TriggerRepeat = Inf;
    vid.Timeout = 10;
    set(getselectedsource(vid),'Brightness',brillo);
    set(getselectedsource(vid),'Contrast',contraste);
    flushdata(vid);
    start(vid);
end

clear data dif N buff time d nombreArchivo t;





