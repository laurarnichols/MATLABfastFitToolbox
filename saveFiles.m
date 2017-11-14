path = 'C:\Users\LJUDY\Desktop\My Stuff\Research\glass\experimentalFitCurves\multiTermGACut\';
composition = {'As28S72'; 'As33S67'; 'As2S3'};
wavelength = [385 532];
power = [15 90];
    
skip = 0;
done = 12;

figNum = 0;
count = 0;
for i = 1:length(composition)
    for j = 1:length(wavelength)
        for k = 1:length(power)
            figNum = figNum + 2;
            count = count + 1;
            
            if count <= done && count > skip
                eval(sprintf('fileName = [path ''intermediate_%s_%d_%d''];', ...
                    composition{i}, wavelength(j), power(k)));
                figure(figNum)
                saveas(gcf,fileName, 'png');

                eval(sprintf('fileName = [path ''final_%s_%d_%d''];', ...
                    composition{i}, wavelength(j), power(k)));
                figure(figNum+1)
                saveas(gcf,fileName, 'png');
            end
        end
    end
end