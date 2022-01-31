function y = criterio_pattern(input, target, inputTest, targetTest)
	%vettore di input
    x=input';
	%vettore target
    t=target';
	%scelta della funzione di addestramento
    trainFcn = 'trainscg'; 
	%numero di neuroni nascosti
    hiddenLayerSize = 5;
	%costruzione della rete 
    net = patternnet(hiddenLayerSize,trainFcn);
	%impostazione del metodo di addestramento
    net.divideFcn = 'dividerand';  
    net.divideMode = 'sample'; 
    net.divideParam.trainRatio = 80/100; 
    net.divideParam.testRatio = 0/100; 
    net.divideParam.valRatio = 20/100; %lasciamo vuoto il validation set
	%impostazione del metodo di valutazione dell'errore a MSE
    net.performFcn = 'crossentropy';
	%scelta delle funzioni di performance da plottare
    net.plotFcns = {'plotperform','plottrainstate', 'plotregression', 'plotconfusion', 'plotfit'};
    %addestramento
    [net, tr]=train(net, x, t);
    output=net(inputTest');
    y=perform(net, targetTest', output);
end

