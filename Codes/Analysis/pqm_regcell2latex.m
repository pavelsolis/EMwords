function fragment = pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex)
% Save a cell array with regression output to Tex file
% Assumptions:
% - regcell does not have column nor row labels
% - The last two rows of regcell report the number of obs. and the R-squared
% - numel(namesrows) == size(regcell,1)
% - namescols has strings of Latex code that once joined equal size(regcell,2)
% - midrules has strings of Latex code with specifics of midrules
% - size(midrules,1) == 2 (two lines with midrule specifics)
% 
% Inputs:
% - regcell is a cell array with regression output ready for printing
%%
frag     = cell(size(regcell,1),1);
fragment = cell(size(regcell,1)+1+numel(midrules),1);

% Add row labels
for k1 = 1:size(regcell,1)
    frag{k1} = strcat(strjoin([namesrows(k1) regcell(k1,:)],' & '),'\\');
end
fragment(3:end-3)   = frag(1:end-2);
fragment(end-1:end) = frag(end-1:end);

% Add column labels
fragment{1} = strcat('&',strjoin(namescols,' & '),'\\');

% Add midrules
fragment{2}     = midrules{1};
fragment{end-2} = midrules{2};

% Save Latex code to Tex file
fid = fopen([nametex,'.tex'],'w');
fprintf(fid,'%s\n',fragment{:});                % \n adds new line breaks
fclose(fid);