x = table2array(TAugmented(:, 1:216));
t = dummyvar(categorical(table2array(TAugmented(:, 217))));

for n=1:30
    %matrici di ingresso e uscita
    disp(n);
    %sequential feature selection
    opts = statset('display', 'iter');
    [fs, history]=sequentialfs(@criterio_pattern, x, t, 'cv', 4, 'options', opts);
	%scrittura dei risultati su file
    if n==1
        fileID=fopen('../seqfspatternFINESTRA2_Smooth.txt', 'w');
    else
        fileID=fopen('../seqfspatternFINESTRA2_Smooth.txt', 'a');
    end
    fprintf(fileID,'%s\n', num2str(find(fs)));
    fclose(fileID);
end
fileID=fopen('../seqfspatternFINESTRA2_Smooth.txt', 'r');
formatSpec = '%u';
features = fscanf(fileID,formatSpec);
[GC, GR] = groupcounts(features);
SelectedT = T(:, [GR(GC >= 4)', 217, 218 ] );


