function printLoop( fid, loop, loopID )
% printLoop: print a line loop

    fprintf(fid, 'Line Loop(%d) = {', loopID);

    for i = 1:size(loop,1)
        % If it's the last line index, close with "};", else separate with comma
        if i == size(loop,1)
            fprintf(fid, '%d};\n', loop(i));
        else
            fprintf(fid, '%d, ', loop(i));
        end
    end
    fprintf(fid, '\n');

end