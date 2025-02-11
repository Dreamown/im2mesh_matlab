%%
V = [0 0;1 0; 1 1; 0 1;];
F = [1 2 3 4];
patch('Faces',F,'Vertices',V,'facecolor',[ .5 .5 .5 ]);

%%
V = [   0 0;
        1 0; 
        1 1; 
        0 1;
        2 0;
        2 1;
    ];
F = [   1 2 3 4;
        2 5 6 3;
    ];

figure; hold on; axis image off;
patch( ...
    'Faces',F, ...
    'Vertices',V, ...
    'facecolor',[ .5 .5 .5 ], ...
    'edgecolor',[.1,.1,.1] );
hold off

%%