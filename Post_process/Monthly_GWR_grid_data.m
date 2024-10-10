clc; clear;
annualPrecipFolder = 'C:\';
monthlyPrecipFolder = 'C:\';
annualGroundwaterFolder = 'C:\'; 
outputFolder = 'C:\';

years = 1980:2020;
months = 1:12;

for year = years
    annualPrecipFile = fullfile(annualPrecipFolder, sprintf('%d.mat', year));
    annualPrecipData = load(annualPrecipFile);
    annualPrecip = annualPrecipData.Prec_rotated; 


    annualGroundwaterFile = fullfile(annualGroundwaterFolder, sprintf('XX.tif'));
    info = geotiffinfo(annualGroundwaterFile);
    annualGroundwater = imread(annualGroundwaterFile);


    for month = months

        monthlyPrecipFile = fullfile(monthlyPrecipFolder, sprintf('%d_%02d.tif', year, month));
        monthlyPrecipinfo = geotiffinfo(monthlyPrecipFile);
        monthlyPrecip = imread(monthlyPrecipFile);

        precipRatio = monthlyPrecip ./ annualPrecip;
        

        monthlyGroundwater = precipRatio .* annualGroundwater;
        

        outputFileName = sprintf('Groundwater_%d_%02d.mat', year, month);
        save(fullfile(outputFolder, outputFileName), 'monthlyGroundwater');
        outputFileName = sprintf('%d_%02d.tif', year, month);
        output_tiff_file = fullfile(outputFolder, outputFileName);
        geotiffwrite(output_tiff_file, monthlyGroundwater, info.RefMatrix);
    end
end
