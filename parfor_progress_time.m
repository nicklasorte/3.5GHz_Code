function percent = parfor_progress_time(app,N)
    %PARFOR_PROGRESS Progress monitor (progress bar) that works with parfor.
    %   PARFOR_PROGRESS works by creating a file called parfor_progress.txt in
    %   your working directory, and then keeping track of the parfor loop's
    %   progress within that file. This workaround is necessary because parfor
    %   workers cannot communicate with one another so there is no simple way
    %   to know which iterations have finished and which haven't.
    %
    %   PARFOR_PROGRESS(N) initializes the progress monitor for a set of N
    %   upcoming calculations.
    %
    %   PARFOR_PROGRESS updates the progress inside your parfor loop and
    %   displays an updated progress bar.
    %
    %   PARFOR_PROGRESS(0) deletes parfor_progress.txt and finalizes progress
    %   bar.
    %
    %   To suppress output from any of these functions, just ask for a return
    %   variable from the function calls, like PERCENT = PARFOR_PROGRESS which
    %   returns the percentage of completion.
    %
    %   Example:
    %
    %      N = 100;
    %      parfor_progress(N);
    %      parfor i=1:N
    %         pause(rand); % Replace with real code
    %         parfor_progress;
    %      end
    %      parfor_progress(0);
    %
    %   See also PARFOR.


    waitMsg='Time Left:';
    percentDoneMsg=' ';
    finishTimeMsg='Total Time:';

    waitSz= length( waitMsg );
    finishSz= length( finishTimeMsg );

    if waitSz > finishSz %%%%To Keep The Display Bar from Shifting Left or Right, this was needed with the delete, not really needed now.
        waitMsgDisp= waitMsg;
        finishTimeMsgDisp= [ repmat( ' ', 1, waitSz - finishSz ),finishTimeMsg ];
    else
        finishTimeMsgDisp= finishTimeMsg;
        waitMsgDisp= [ repmat( ' ', 1, finishSz - waitSz ), waitMsg ];
    end

    narginchk(1, 2)

    if nargin < 2 %%%1
        N = -1;
    end

    percent = 0;
    w = 25;%50; % Width of progress bar

    if N > 0
        f = fopen('parfor_progress.txt', 'w');
        if f<0
            error('Do you have write permissions for %s?', pwd);
        end
        ticInit= tic;
        fprintf(f, '%ld\n', ticInit );    % Save the initial tic mark at the top of progress.txt
        fprintf(f, '%d\n', N); % Save N at the top of progress.txt
        fclose(f);

        if nargout == 0
            percent=0;
            textWidth=length(waitMsgDisp) + 3 + 1 + 2 + 1 + 4 + length(percentDoneMsg) + 1 + 2 + 1;
            statusMsg=[ repmat( ' ', 1, textWidth-4 ),'  0%' ];

            x= round( percent * w / 100 );
            marker= '>';
            if x < w
                bar= [ ' [', repmat( '=', 1, x ), marker,repmat( ' ', 1, w - x - 1 ), ']' ];
            else
                bar= [ ' [', repmat( '=', 1, x ),repmat( ' ', 1, w - x ), ']' ];
            end
            statusLine= [ statusMsg, bar ];
            disp_progress(app,statusLine)
        end
    elseif N == 0
        
        if ~exist('parfor_progress.txt', 'file')
            error('parfor_progress.txt not found. Run PARFOR_PROGRESS(N) before PARFOR_PROGRESS to initialize parfor_progress.txt.');
        end

        f = fopen('parfor_progress.txt', 'r');
        [ readbuffer, progressCountPlus2 ]= fscanf( f, '%ld' );
        fclose(f);

        ticInit= uint64( readbuffer(1) );
        timeElapsed= toc( ticInit );
        
        delete('parfor_progress.txt');
        percent = 100;
        
        hh= fix( timeElapsed / 3600 );
        mm= fix( ( timeElapsed - hh * 3600 ) / 60 );
        ss= max( ( timeElapsed - hh * 3600 - mm * 60 ), 0.1 );
        obj_format= [ '%03d:%02d:%04.1f' percentDoneMsg '%3.0f%%'];  % hh:mm:ss.s % 4 characters wide, percentage
        timedMsg = sprintf( obj_format, hh, mm, ss, percent );
        
        
        statusMsg=[ finishTimeMsgDisp timedMsg ];
        x= round( percent * w / 100 );
        marker= '>';
        if x < w
            bar= [ ' [', repmat( '=', 1, x ),marker,repmat( ' ', 1, w - x - 1 ), ']' ];
        else
            bar= [ ' [', repmat( '=', 1, x ),repmat( ' ', 1, w - x ), ']' ];
        end
        statusLine= [ statusMsg, bar ];

        %%%%%%%This makes it display the status in the text area
        if nargout == 0
            disp_progress(app,statusLine)
        end

    else
        if ~exist('parfor_progress.txt', 'file')
            error('parfor_progress.txt not found. Run PARFOR_PROGRESS(N) before PARFOR_PROGRESS to initialize parfor_progress.txt.');
        end

        %%%%Might have to comment out these 3 lines below
        f = fopen('parfor_progress.txt', 'a');
        fprintf(f, '1\n');
        fclose(f);

        f = fopen('parfor_progress.txt', 'r');
        [ readbuffer, progressCountPlus2 ]= fscanf( f, '%ld' );
        fclose(f);

        ticInit= uint64( readbuffer(1) );
        timeElapsed= toc( ticInit );

        progressCount= progressCountPlus2 - 2;
        targetCount= double( readbuffer(2) );       % avoids Matlab's buggy assumption of readbuffer type as uint64

        percent = progressCount * 100 / targetCount;
        if percent > 0
            remainingTime= timeElapsed * ( 100 / percent - 1 );
        else
            %remainingTime= timeElapsed * 200;   % initial duration estimate
            remainingTime= timeElapsed * N;   % initial duration estimate
        end

        hh= fix( remainingTime / 3600 );
        mm= fix( ( remainingTime - hh * 3600 ) / 60 );
        ss= max( ( remainingTime - hh * 3600 - mm * 60 ), 0.1 );
        obj_format= [ '%03d:%02d:%04.1f' percentDoneMsg '%3.0f%%'];  % hh:mm:ss.s % 4 characters wide, percentage
        timedMsg = sprintf( obj_format, hh, mm, ss, percent );

        statusMsg=[ waitMsgDisp timedMsg ];
        x= round( percent * w / 100 );
        marker= '>';
        if x < w
            bar= [ ' [', repmat( '=', 1, x ),marker,repmat( ' ', 1, w - x - 1 ), ']' ];
        else
            bar= [ ' [', repmat( '=', 1, x ),repmat( ' ', 1, w - x ), ']' ];
        end
        statusLine= [ statusMsg, bar ];

        %%%%%%%This makes it display the status in the text area
        if nargout == 0
            disp_progress(app,statusLine)
        end
    end
end


