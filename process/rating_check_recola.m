clear all
close all
clc

%%
%path of the ratings directory
directory = '/Users/fabienringeval/Documents/Databases/EXP3/Ratings/new/';

%path for saving ratings
save_path = '/Users/fabienringeval/Documents/Databases/EXP3/Ratings/processed/';

dimensions=cell(1,2);
dimensions{1}='arousal';
dimensions{2}='valence';
raters=cell(1,16);
raters{1}='FM1_1HZ89ZEN';
raters{2}='FM2_H872B5ZA'; 
raters{3}='FM3_IZ20HG98';
raters{4}='FM4_9BC62NY0';
raters{5}='FF1_W8A3NR99'; 
raters{6}='FF2_PBT190NY';
raters{7}='FF3_0B67OATB'; 
raters{8}='FF4_8ZCB467T';
raters{9}='NFM1_C2AB7HT5'; 
raters{10}='NFM2_7CT2ZGE4'; 
raters{11}='NFM3_ZBP79GRZ'; 
raters{12}='NFM4_3T97C14G'; 
raters{13}='NFF1_2C839Y74'; 
raters{14}='NFF2_C07TBY12'; 
raters{15}='NFF3_6VZE5U6U'; 
raters{16}='NFF4_0B671C44';

raters_name{1}='FM1';%-Fist_name Last_name';
raters_name{2}='FM2';%-XXX XXX';
raters_name{3}='FM3';%-XXX XXX';
raters_name{4}='';
raters_name{5}='FF1';%-XXX XXX';
raters_name{6}='FF2';%-XXX XXX';
raters_name{7}='FF3';%-XXX XXX';
raters_name{8}='';
raters_name{9}='NFM1';%-XXX XXX';
raters_name{10}='';
raters_name{11}='';
raters_name{12}='';
raters_name{13}='';
raters_name{14}='';
raters_name{15}='';
raters_name{16}='';

%%%%%%depend on the text file saved by the server during annotation!
N_soc_dim=5;%number of rated social dim
N_fields_emo=11;%number of fields when dim is emotion
ind_seq_emo=7;%field index of rated sequence
N_fields_soc=8;%number of fields when dim is social
ind_seq_soc=3;%field index of rated sequence

%%%%%%constant that can be overflooded (used for declaration only)
Nseqrat_max=500;%max number of continuous ratings for all sequences; =500
Nrat_max=30000;%max number of ratings for one sequence; one rating each 10ms (each sequence is 300 sec. length); =30000
N_ratmax=length(raters);%max number of raters
N_mulrat_min=20;%max number of multiple ratings for one sequence; =20

%%%%%%constant for annotation checking
max_dur_dim=600;%max duration of annotation (10 min for 5 min of video); =600 seconds
max_delay=5;%max delay (after start / before end of sequence) of annotation; =5 seconds
max_delay_in=20;%max delay bewteen two annotation samples; =20 seconds
max_delay_be=120+2*max_dur_dim;%maximum delay bewteen first and last sample from arousal and valence annotations, respectively; =120 seconds
seq_dur=300;%sequence duration; =300 seconds
N_seq_max=46;%total number of sequence to rate
Fe_vid=25;%video frame rate; =25 fps

%%%%%%%sequence and dim checking bypass for server delays (re-annotation of a sequence)
rater_by_pass=cell(1,N_ratmax);
for rater=1:N_ratmax,
    rater_by_pass{rater}=zeros(2,N_seq_max);
    for seq=1:N_seq_max,
        for dim=0:1,
            if rater==1
                if seq==3 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==5 || seq==6,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==8 && dim==1,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==15 && dim==1,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==25 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==26 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==29 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==35,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==36 || seq==37 || seq==39 || seq==40,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
            end

            if rater==2
                if seq==1 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==8 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==20,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==21 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
            end
            
            if rater==3
                if seq==20,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
            end
            
            if rater==5
                if seq==2 && dim==1 || seq==38,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
            end
            
            if rater==6
                rater_by_pass{rater}(:,seq)=1;
            end
            
            if rater==7
                rater_by_pass{rater}(:,seq)=1;
            end
            
            if rater==9
                if seq==1,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==6 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==9 && dim==0,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
                if seq==11 || seq==19 || seq==22 || seq==24 || seq==42 || seq==45 || seq==46,
                    rater_by_pass{rater}(dim+1,seq)=1;
                end
            end
        end
    end
end

%

%loop on raters
for rater=1:8,
    file=dir([directory raters{rater} '.csv']);
    if ~isempty(file),
        time=clock;
        disp('------------------------------------------------------------------------------------------------------------------')
        fprintf(['RECOLA annotation checking report | ' datestr(time) '\n\n'])

        %% read ratings and extract continous annotation
        
        %read previous saved data
        fprintf(['-> Reading previous annotation from coder #' num2str(rater) ': ' raters_name{rater} '; '])
        loading_pre=0;
        try
           data_pre=load([save_path raters{rater} '.trace'],'-MAT');
           loading_pre=1;
           line=data_pre.save_lrl+1;%do jump if previous data were all correctly saved
           dur_ano_ser=data_pre.save_duranoser;
           fprintf('file correctly loaded!\n\n')
        catch msg,
            line=1;
            dur_ano_ser=zeros(1,N_seq_max);
            fprintf('file does not exist.\n\n')
        end

        fprintf(['-> Reading annotation data from coder #' num2str(rater) ': ' raters_name{rater}])
        fid=fopen([directory file.name]);
        data=textscan(fid,'%s','delimiter','\n');
        data=data{1};
        N_lines=length(data);

        %prepare outpout
        info_ratings=zeros(Nseqrat_max,2);%num_seq, dimension (0:arousal, 1:valence, 2:social)
        ratings=cell(1,Nseqrat_max);%ratings
        l_start=line;ind_rat_seq=0;save_val=0;
        
        %process lines until end of file
        if line<=N_lines,fprintf('\n   progress: 0%% '),end
        while line<=N_lines,
            if mod(round(100*(line-l_start)/N_lines),10)==0 && round(100*(line-l_start)/N_lines)>save_val,
                save_val=round(100*line/N_lines);
                fprintf('%d%% ',save_val)
            end
            fields=textscan(data{line},'%s','delimiter',',');
            fields=fields{1};
            
            %identify the rated dimension
            switch length(fields),
                case N_fields_emo
                    ind_field=ind_seq_emo;
                    if strcmp(fields{ind_field+1},'arousal'),
                        arovalsoc=0;
                    else
                        arovalsoc=1;
                    end
                case N_fields_soc
                    ind_field=ind_seq_soc;
                    arovalsoc=2;
            end
            
            %process data only if the rated sequence is not a demo
            if isempty(strfind(fields{ind_field},'DEMO')),
                ind_rat_seq=ind_rat_seq+1;

                %num sequence
                ind=strfind(fields{ind_field},'_');
                ind2=strfind(fields{ind_field},'.');
                seq=str2double(fields{ind_field}(ind+1:ind2-1));
                
                %save info
                info_ratings(ind_rat_seq,1)=seq;
                info_ratings(ind_rat_seq,2)=arovalsoc;
                
                %extract ratings
                if arovalsoc~=2,
                    ratings{ind_rat_seq}=zeros(Nrat_max,3);%server time code, rating time code, rating value 
                    flag=1;ind_rat=0;
                    while flag,
                        if mod(round(100*line/N_lines),10)==0 && round(100*line/N_lines)>save_val,
                            save_val=round(100*line/N_lines);
                            if save_val~=100,
                                fprintf('%d%% ',save_val)
                            else
                                fprintf('%d%%',save_val)
                            end
                        end
                        ind_rat=ind_rat+1;

                        %test if fields info are same and time code consecutive otherwise it is a new sequence
                        if ind_rat>1,
                            %rated dimension
                            switch length(fields),
                                case N_fields_emo
                                    ind_field=ind_seq_emo;
                                    %timecode
                                    new_timecode=str2double(fields{ind_field+2});
                                    if strcmp(fields{ind_field+1},'arousal'),
                                        new_arovalsoc=0;
                                    else
                                        new_arovalsoc=1;
                                    end
                                case N_fields_soc
                                    ind_field=ind_seq_emo;
                                    new_arovalsoc=2;
                            end
                            %num sequence
                            ind=strfind(fields{ind_field},'_');
                            ind2=strfind(fields{ind_field},'.');
                            new_seq=str2double(fields{ind_field}(ind+1:ind2-1));
                            
                            %test if config are the same
                            if seq==new_seq && arovalsoc==new_arovalsoc,
                                if new_timecode>=timecode,
                                    %extract timing
                                    server_tcode=str2double(fields{ind_field-2});
                                    timecode=str2double(fields{ind_field+2});
                                    rating=str2double(fields{ind_field+3});
                                    %save data
                                    ratings{ind_rat_seq}(ind_rat,1)=server_tcode;
                                    ratings{ind_rat_seq}(ind_rat,2)=timecode;
                                    ratings{ind_rat_seq}(ind_rat,3)=rating;
                                    %and read the next line
                                    line=line+1;
                                    if line<=N_lines,
                                        fields=textscan(data{line},'%s','delimiter',',');
                                        fields=fields{1};
                                    else
                                        flag=0;
                                    end
                                else%test if delay is due to server
                                    new_server_tcode=str2double(fields{ind_field-2});
                                    %save data if true
                                    if new_server_tcode<server_tcode || abs(new_timecode-timecode)<1,
                                        %extract timing
                                        server_tcode=str2double(fields{ind_field-2});
                                        timecode=str2double(fields{ind_field+2});
                                        rating=str2double(fields{ind_field+3});
                                        %save data
                                        ratings{ind_rat_seq}(ind_rat,1)=server_tcode;
                                        ratings{ind_rat_seq}(ind_rat,2)=timecode;
                                        ratings{ind_rat_seq}(ind_rat,3)=rating;
                                        %and read the next line
                                        line=line+1;
                                        if line<=N_lines,
                                            fields=textscan(data{line},'%s','delimiter',',');
                                            fields=fields{1};
                                        else
                                            flag=0;
                                        end
                                    else%break otherwise
                                        flag=0;
                                    end
                                end
                            else
                                flag=0;
                            end
                        else%first run, just save data
                            %extract info
                            server_tcode=str2double(fields{ind_field-2});
                            timecode=str2double(fields{ind_field+2});
                            rating=str2double(fields{ind_field+3});
                            %save data
                            ratings{ind_rat_seq}(ind_rat,1)=server_tcode;
                            ratings{ind_rat_seq}(ind_rat,2)=timecode;
                            ratings{ind_rat_seq}(ind_rat,3)=rating;
                            %and read the next line
                            line=line+1;
                            if line<=N_lines,
                                fields=textscan(data{line},'%s','delimiter',',');
                                fields=fields{1};
                            else
                                flag=0;
                            end
                        end
                    end
                    %keep only non-zeros values of time code (matrix oversize declaration)
                    ind=logical(ratings{ind_rat_seq}(:,2));
                    ratings{ind_rat_seq}=ratings{ind_rat_seq}(ind,:);
                    %order ratings since timecode may not be consecutive
                    [ind1, ind2]=sort(ratings{ind_rat_seq}(:,2));
                    ratings{ind_rat_seq}=ratings{ind_rat_seq}(ind2,:);
                    %filter out ratings with same time code (moving cursor when video is stopped)
                    ind=find(diff(ratings{ind_rat_seq}(:,2))==0);%list of time code with same values
                    if ~isempty(ind),
                        %segment the list into parts
                        ind2=find(diff(ind)>1)+1;
                        if isempty(ind2),
                            ratings{ind_rat_seq}([ind(2:end) ; ind(end)+1],:)=zeros(length(ind),3);
                            ind=find(ratings{ind_rat_seq}(:,1));
                            ratings{ind_rat_seq}=ratings{ind_rat_seq}(ind,:);
                        else
                            if(size(ind2,1)>size(ind2,2)),ind2=ind2';end
                            indstr=[1 ind2];
                            indstp=[ind2-1 length(ind)];
                            N=length(ind2)+1;                            
                            for i=1:N,
                                if indstp(i)==indstr(i),
                                    ratings{ind_rat_seq}(ind(indstr(i))+1,:)=zeros(1,3);
                                else 
                                    ratings{ind_rat_seq}(ind(indstr(i))+1:ind(indstp(i))+1,:)=zeros(length(ind(indstr(i))+1:ind(indstp(i)))+1,3);
                                end
                            end
                            ind=find(ratings{ind_rat_seq}(:,1));
                            ratings{ind_rat_seq}=ratings{ind_rat_seq}(ind,:);
                        end
                    end
                else
                    %extract social ratings
                    ratings{ind_rat_seq}=zeros(1,N_soc_dim);%rating value 
                    for i=1:N_soc_dim,
                        ratings{ind_rat_seq}(i)=str2double(fields{ind_field+i});
                    end
                    line=line+1;
                end
            else
                line=line+1;
            end
        end
        if l_start<=N_lines,
            fprintf('; done!\n\n'),
        else
            fprintf('; no update available!\n\n'),
        end
        
        %% group multiple annotations of a same sequence
        Last_rat_seq=max(info_ratings(:,1));
        info_ratings=info_ratings(1:ind_rat_seq,:);
        rated_seq=unique(info_ratings(:,1));
        NN_rated_seq=length(rated_seq);
        
        if NN_rated_seq,
            %prepare output
            gath_ratings_aro=cell(Last_rat_seq,N_mulrat_min);
            gath_ratings_val=cell(Last_rat_seq,N_mulrat_min);
            gath_ratings_soc=cell(Last_rat_seq,N_mulrat_min);
            %%
            for seq=rated_seq',
                %process continuous ratings first
                for dim=0:1,
                    ind=find(info_ratings(:,1)==seq & info_ratings(:,2)==dim)';
                    if ~isempty(ind) && (~loading_pre || ~data_pre.save_sequence(seq)),
                        cpt_val=1;
                        switch dim,
                            case 0
                                for i=ind,
                                    gath_ratings_aro{seq,cpt_val}=ratings{i};
                                    cpt_val=cpt_val+1;
                                end
                            case 1
                                for i=ind,
                                    gath_ratings_val{seq,cpt_val}=ratings{i};
                                    cpt_val=cpt_val+1;
                                end
                        end
                    end
                end
                %then process social ratings
                ind=find(info_ratings(:,1)==seq & info_ratings(:,2)==2)';
                if ~isempty(ind),
                    cpt_val=1;
                    for i=ind,
                        gath_ratings_soc{seq,cpt_val}=ratings{i};
                        cpt_val=cpt_val+1;
                    end
                end
            end
            N_mulrat_max=max(diff([0 find(diff(sort(info_ratings(:,1))))']));
            %% test if the duration took to annotate a sequence is inferior to max_dur_dim, and if delay after start and before end are ok too
            %%%+ server delay between first and last annnotation + delay between two consecutive ratings in a same annotation
            fprintf('->  1st pass checking: duration and delays of each annotation\n')
            test_durano_aro=zeros(1,Last_rat_seq); test_durano_val=zeros(1,Last_rat_seq);
            for seq=rated_seq',
                for dim=0:1,
                    min_tcod=inf;max_tcod=0;
                    min_scod=inf;max_scod=0;
                    for rat=1:N_mulrat_min,
                        if dim==0,
                            val_t_tmp=gath_ratings_aro{seq,rat};
                        else
                            val_t_tmp=gath_ratings_val{seq,rat};
                        end
                        if ~isempty(val_t_tmp),
                            %video timecode
                            min_val=min(val_t_tmp(:,2));
                            if min_val<min_tcod,min_tcod=min_val;end
                            max_val=max(val_t_tmp(:,2));
                            if max_val>max_tcod,max_tcod=max_val;end
                            
                            %server timecode
                            min_val=min(val_t_tmp(:,1));
                            if min_val<min_scod,min_scod=min_val;end
                            max_val=max(val_t_tmp(:,1));
                            if max_val>max_scod,max_scod=max_val;end
                            
                            %sum of annoation time
                            valtmp=diff(val_t_tmp(:,1))'/1e3;
                            valtmp=valtmp(logical(valtmp<60));
                            valtmp=sum(valtmp);
                            dur_ano_ser(seq)=dur_ano_ser(seq)+valtmp;
                        end
                    end
                    if (dim==0 && ~isempty(gath_ratings_aro{seq,1})) || (dim==1 && ~isempty(gath_ratings_val{seq,1})),
                        if dim==0 && seq==rated_seq(1),fprintf('\n'),end
                        fprintf(['     ->  Sequence ' num2str(seq) ', ' dimensions{dim+1} ': '])
                        flag_ok=1;
                        %checking starting / ending delay in video time codes
                        if min_tcod>max_delay,
                            flag_ok=0;
                            fprintf(['too long starting delay: ' num2str(round(min_tcod)) ' s.; '])
                        end
                        if max_tcod<seq_dur-max_delay_in,
                            flag_ok=0;
                            fprintf(['too long ending delay: ' num2str(round(max_tcod)) '/' num2str(seq_dur) ' s.; '])
                        end
                        %checking starting / ending delay in server time codes
                        if round((max_scod-min_scod)/1e3)>max_dur_dim && ~rater_by_pass{rater}(dim+1,seq),
                            flag_ok=0;
                            fprintf(['too long delay between annotations: ' num2str(round(((max_scod-min_scod)/1e3)/60)) ' min.'])
                        end
                        if flag_ok,
                            switch dim,
                                case 0
                                    test_durano_aro(seq)=1;
                                case 1
                                    test_durano_val(seq)=1;
                            end
                            fprintf('OK!')
                        end
                        fprintf('\n')
                    end
                end
            end
            fprintf('\n'),

            %% fuse multiple ratings from retained annotations + check delay between samples check delay and order of annotation +
            if any(test_durano_aro) || any(test_durano_val),
                fprintf('->  2nd pass checking: delay bewteen samples (fusion of multiple ratings)\n\n')
                fused_ratings_aro=cell(1,Last_rat_seq); fused_ratings_val=cell(1,Last_rat_seq); fused_ratings_soc=NaN*ones(N_soc_dim,Last_rat_seq);
                for seq=rated_seq',
                    for dim=0:1,
                        flag_proc=0;
                        switch dim,
                            case 0,
                                if test_durano_aro(seq),
                                    data=gath_ratings_aro{seq,1};%initialise output with first rating
                                    flag_proc=1;
                                end
                            case 1,
                                if test_durano_val(seq),
                                    data=gath_ratings_val{seq,1};
                                    flag_proc=1;
                                end
                        end
                        if flag_proc,
                            fprintf(['     ->  Sequence ' num2str(seq) ', ' dimensions{dim+1} ': '])
                            for rat=2:N_mulrat_max,
                                new_data=[];
                                switch dim,
                                    case 0,
                                        if rat<=size(gath_ratings_aro,2) && ~isempty(gath_ratings_aro{seq,rat}),
                                            new_data=gath_ratings_aro{seq,rat};
                                        end
                                    case 1,
                                        if rat<=size(gath_ratings_val,2) && ~isempty(gath_ratings_val{seq,rat}),
                                            new_data=gath_ratings_val{seq,rat};
                                        end
                                end
                                if ~isempty(new_data),
                                    ind_start=new_data(1,2); ind_stop=new_data(end,2);
                                    if ind_stop-ind_start>10 && size(new_data,1)>10,
                                        indsta=find(data(:,2)<ind_start);
                                        indsto=find(data(:,2)>ind_stop);
                                        data=[data(indsta,:) ; new_data ; data(indsto,:)];%insert new rating
                                    end
                                end
                            end
                            %check max delay bewteen samples
                            if max(diff(data(:,2)))<max_delay_in,
                                switch dim,
                                    case 0,
                                        fused_ratings_aro{seq}=data;
                                        test_durano_aro(seq)=2;
                                    case 1,
                                        fused_ratings_val{seq}=data;
                                        test_durano_val(seq)=2;
                                end
                                fprintf('OK!\n')
                            else
                                ind=find(diff(data(:,2))>max_delay_in);
                                if length(ind)==1,
                                    fprintf(['too long delay between annotation samples, at ' num2str(round(data(ind,2))) ' s., delay is equal to ' num2str(round(max(diff(data(:,2))))) ' s.\n'])
                                else
                                    fprintf(['too long delay between annotation samples, at [' num2str(round(data(ind(1),2)))])
                                    for j=2:length(ind),
                                        fprintf([',' num2str(round(data(ind(j),2)))])
                                    end
                                    fprintf(['] s., delay is equal to [' num2str(round(diff(data(ind(1):ind(1)+1,2))))])
                                    for j=2:length(ind),
                                        fprintf([',' num2str(round(diff(data(ind(j):ind(j)+1,2))))])
                                    end
                                    fprintf('] s.\n')
                                end
                            end
                        end
                    end
                    rat=1;
                    while ~isempty(gath_ratings_soc{seq,rat}),
                        fused_ratings_soc(:,seq)=gath_ratings_soc{seq,rat}';
                        rat=rat+1;
                    end
                end
                fprintf('\n')
                if ~any(test_durano_aro==2) && ~any(test_durano_val==2),
                    fprintf(['->  No sequence passed 2nd check, end of report for coder #' num2str(rater) ': ' raters_name{rater} '\n'])
                end
            else
                fprintf(['->  No sequence passed 1st check, end of report for coder #' num2str(rater) ': ' raters_name{rater} '\n'])
            end
            
            %% check delay and order of annotations
            if any(test_durano_aro==2) || any(test_durano_val==2),
                fprintf('->  3nd pass checking: delay and order of annotations\n\n')
                for seq=rated_seq',
                    if test_durano_aro(seq)==2 || test_durano_val(seq)==2,
                        fprintf(['     ->  Sequence ' num2str(seq) ': '])
                        flag_proc=1;
                        if ~(test_durano_aro(seq)==2),
                            fprintf('arousal rating is missing or not validated; '),flag_proc=0;
                        end
                        if ~(test_durano_val(seq)==2),
                            fprintf('valence rating is missing or not validated; '),flag_proc=0;
                        end
                        if all(isnan(fused_ratings_soc(:,seq))),
                            fprintf('social rating is missing'),flag_proc=0;
                        end
                        
                        if flag_proc,
                            %check order first (social rating just after each arousal or valence)
                            last_arorat=find(info_ratings(:,1)==seq & info_ratings(:,2)==0);
                            last_arorat=last_arorat(end);
                            last_valrat=find(info_ratings(:,1)==seq & info_ratings(:,2)==1);
                            last_valrat=last_valrat(end);
                            last_socrat=find(info_ratings(:,1)==seq & info_ratings(:,2)==2);
                            last_socrat=last_socrat(end);
                            
                            if last_socrat==last_arorat+1 || last_socrat==last_valrat+1 || any(rater_by_pass{rater}(:,seq)),
                                aro_starat=min(fused_ratings_aro{seq}(:,1));aro_storat=max(fused_ratings_aro{seq}(:,1));
                                val_starat=min(fused_ratings_val{seq}(:,1));val_storat=max(fused_ratings_val{seq}(:,1));
                                starat=min(aro_starat,val_starat);storat=max(aro_storat,val_storat);
                                if (storat-starat)>max_delay_be*1e3 && ~any(rater_by_pass{rater}(:,seq)),
                                    fprintf(['delay between first and last annotation is too long: ' num2str(round((storat-starat)/1e3)) ' s.\n'])
                                else
                                    fprintf('OK!\n')
                                    test_durano_aro(seq)=3;test_durano_val(seq)=3;
                                end
                            else
                                fprintf('social rating was performed before last arousal/valence rating or after the rate of a new sequence\n')
                            end
                        else
                            fprintf('\n')
                        end
                    end
                end
                fprintf('\n')
            end

            %% binning ratings according to video frame
            if any(test_durano_aro==3) || any(test_durano_val==3),
                fprintf('->  Binning retained annotations\n\n')
                bined_ratings_aro=cell(1,Last_rat_seq); bined_ratings_val=cell(1,Last_rat_seq);
                binning_val=0:1/Fe_vid:seq_dur;
                saved_seq=find(test_durano_aro==3 & test_durano_val==3);
                
                N_binval=seq_dur*Fe_vid+1;
                for seq=saved_seq,
                    for dim=0:1,
                        flag_proc=0;
                        switch dim,
                            case 0,
                                if test_durano_aro(seq)==3,
                                    data=fused_ratings_aro{seq};%get ratings
                                    flag_proc=1;
                                end
                            case 1,
                                if test_durano_val(seq)==3,
                                    data=fused_ratings_val{seq};
                                    flag_proc=1;
                                end
                        end
                        if flag_proc,
                            data_output=NaN*ones(1,N_binval);%initialise output
                            if dim==0,fprintf(['     ->  Sequence ' num2str(seq) ': processing']),end
                            %process first bin
                            binstr=0;binstp=mean(binning_val(1:2));
                            ind=find(data(:,2)>binstr & data(:,2)<binstp);
                            if ~isempty(ind),
                                data_output(1)=mean(data(ind,3));
                            end
                            fprintf('.')
                            for bin=2:N_binval-1,
                                binstr=mean(binning_val(bin-1:bin)); binstp=mean(binning_val(bin:bin+1));
                                ind=find(data(:,2)>binstr & data(:,2)<binstp);
                                if ~isempty(ind),
                                    data_output(bin)=mean(data(ind,3));
                                end
                            end
                            fprintf('.')
                            %process last bin
                            binstr=mean(binning_val(end-1:end));binstp=binning_val(end);
                            ind=find(data(:,2)>binstr & data(:,2)<binstp);
                            if ~isempty(ind),
                                data_output(end)=mean(data(ind,3));
                            end
                            ind=find(~isnan(data_output));
                            data_output(ind(1):ind(end))=pchip(binning_val(ind),data_output(ind),binning_val(ind(1):ind(end)));
                            fprintf('.')
                            %save data
                            switch dim,
                                case 0,
                                    bined_ratings_aro{seq}=data_output;
                                case 1,
                                    bined_ratings_val{seq}=data_output;
                            end
                            if dim==1,fprintf(' done!\n'),end
                        end
                    end
                end
                fprintf('\n')
                %load previously saved data
                try
                    data=load([save_path raters{rater} '.trace'],'-MAT');%save_binrataro,save_binratval,save_sequence
                    save_fusrataro=data.save_fusrataro;
                    save_fusratval=data.save_fusratval;
                    save_binrataro=data.save_binrataro;
                    save_binratval=data.save_binratval;
                    save_sequence=data.save_sequence;
                    save_socrat=data.save_socrat;
                    save_duranoser=data.save_duranoser;
                    fprintf('->  Updating saved data with new retained annotations...')
                catch msg,
                    %1st save for coder #rater
                    save_fusrataro=cell(1,N_seq_max);
                    save_fusratval=cell(1,N_seq_max);
                    save_binrataro=cell(1,N_seq_max);
                    save_binratval=cell(1,N_seq_max);
                    save_sequence=zeros(1,N_seq_max);
                    save_duranoser=zeros(1,N_seq_max);
                    save_socrat=zeros(N_soc_dim,N_seq_max);
                    fprintf('->  Saving data from retained annotations...')
                end
                %save data / update saved data
                for seq=saved_seq,
                    save_fusrataro{seq}=fused_ratings_aro{seq};
                    save_fusratval{seq}=fused_ratings_val{seq};
                    save_binrataro{seq}=bined_ratings_aro{seq};
                    save_binratval{seq}=bined_ratings_val{seq};
                    save_sequence(seq)=seq;
                    save_duranoser(seq)=dur_ano_ser(seq);
                    save_socrat(:,seq)=fused_ratings_soc(:,seq);
                end
                
                %if all rated sequences were correctly made and thus saved -> save last read line (N_lines) to speed up text file reading next time
                cpt=length(find(save_sequence));
                fprintf(' done!\n\n')
                fprintf(['-> Report summary: |Rated| = ' num2str(rated_seq(end)) ', |Validated| = ' num2str(cpt) ', |To do again| = ' num2str(rated_seq(end)-cpt) ', |Resting| = ' num2str(N_seq_max-rated_seq(end)) ', |To perform| = ' num2str(N_seq_max-cpt) '\n\n'])
                
                total_time=sum(save_duranoser)/60;%+153 min for pauses
                tt_min=round((total_time/60-fix(total_time/60))*60);if tt_min<10,tt_min=['0' num2str(tt_min)];else num2str(tt_min);end,tt_min=num2str(tt_min);
                tt_hour=num2str(fix(total_time/60));
                if rated_seq(end)==cpt,
                    save_lrl=N_lines;
                    fprintf(['-> End of report for coder #' num2str(rater) ': ' raters_name{rater} ', total time of work to be paid: ' tt_hour 'h' tt_min '''\n'])
                else
                    save_lrl=l_start-1;
                    fprintf(['-> End of report for coder #' num2str(rater) ': ' raters_name{rater} ' (bypass will be required), total time of work to be paid: ' tt_hour 'h' tt_min '''\n'])
                end
                save([save_path raters{rater} '.trace'],'save_fusrataro','save_fusratval','save_binrataro','save_binratval','save_sequence','save_socrat','save_lrl','save_duranoser')
                
            elseif any(test_durano_aro==2) || any(test_durano_val==2),
                cpt=length(find(data_pre.save_sequence));
                fprintf(['-> Report summary: |Rated| = ' num2str(rated_seq(end)) ', |Validated| = ' num2str(cpt) ', |To do again| = ' num2str(rated_seq(end)-cpt) ', |Resting| = ' num2str(N_seq_max-rated_seq(end)) ', |To perform| = ' num2str(N_seq_max-cpt) '\n\n'])
                total_time=sum(dur_ano_ser+153)/60;
                tt_min=round((total_time/60-fix(total_time/60))*60);if tt_min<10,tt_min=['0' num2str(tt_min)];else num2str(tt_min);end,tt_min=num2str(tt_min);
                tt_hour=num2str(fix(total_time/60));
                fprintf(['->  End of report for coder #' num2str(rater) ': ' raters_name{rater} ', no sequence passed 3rd check, total time of work to be paid: ' tt_hour 'h' tt_min '''\n'])
            end
            fprintf('\n')
        end
    end
end

%uncomment for plotting, post-processing, analysis and save in text files commands
%
% %% plot
% plt_opt={'b','r','k','r+','c','m','g','r+','b+','g+'};
% 
% data_rater=cell(1,N_ratmax);
% for rater=1:N_ratmax,
%     file=dir([save_path raters{rater} '.trace']);
%     if ~isempty(file),
%         data_rater{rater}=load([save_path file.name],'-MAT');
%     end
% end
% 
% % seq=1;
% close all
% for seq=2,
%     cpt=0;
%     legend_name=cell(1,8);
%     for rater=1:16,
%         if ~isempty(data_rater{rater}) && data_rater{rater}.save_sequence(seq),
%             cpt=cpt+1;
% %             data_tmp=data_rater{rater}.save_fusrataro{seq};
%             data_tmp=data_rater{rater}.save_binrataro{seq};
%             figure(seq),hold on,plot((1:length(data_tmp))/Fe_vid,data_tmp,plt_opt{cpt}),hold off
%             data_tmp=data_tmp-nanmean(data_tmp);
%             figure(seq+10),hold on,plot((1:length(data_tmp))/Fe_vid,data_tmp,plt_opt{rater}),hold off
% 
% %             data_tmp=data_rater{rater}.save_fusratval{seq};
%             data_tmp=data_rater{rater}.save_binratval{seq};
%             figure(seq+100),hold on,plot((1:length(data_tmp))/Fe_vid,data_tmp,plt_opt{cpt}),hold off
%             data_tmp=data_tmp-nanmean(data_tmp);
%             figure(seq+110),hold on,plot((1:length(data_tmp))/Fe_vid,data_tmp,plt_opt{rater}),hold off
% 
%                         legend_name{cpt}=strrep(raters_name{rater},'_',' ');
%         end
%     end
%     figure(seq),xlabel('time in seconds'),ylabel('rated value'),title(['Rating of emotional arousal - seq ' num2str(seq)]),axis([0,300,-1 1]),legend({legend_name{1:cpt}})%#ok<*CCAT1>
%     figure(seq+10),xlabel('time in seconds'),ylabel('rated value'),title(['Rating of emotional arousal: mean centered values - seq ' num2str(seq)]),axis([0,300,-1 1]),legend({legend_name{1:cpt}})
%     figure(seq+100),xlabel('time in seconds'),ylabel('rated value'),title(['Rating of emotional valence - seq ' num2str(seq)]),axis([0,300,-1 1]),legend({legend_name{1:cpt}})%#ok<*CCAT1>
%     figure(seq+110),xlabel('time in seconds'),ylabel('rated value'),title(['Rating of emotional valence: mean centered values - seq ' num2str(seq)]),axis([0,300,-1 1]),legend({legend_name{1:cpt}})
% end
% 
% 
% 
% 
% %% post-processings of ratings
% 
% data_rater=cell(1,N_ratmax);
% for rater=1:N_ratmax,
%     file=dir([save_path raters{rater} '.trace']);
%     if ~isempty(file),
%         data_rater{rater}=load([save_path file.name],'-MAT');
%     end
% end
% 
% 
% %Number of sequences
% N_seq=46;
% %Number of raters
% Nr=6;list=1:Nr;
% %sampling frequency of traces
% Fe=25;
% %max time delay in second used to sync traces
% max_sdelay=2;
% %social dimensions
% social_dim=cell(1,N_soc_dim);
% social_dim{1}='agreement';
% social_dim{2}='engagement';
% social_dim{3}='dominance';
% social_dim{4}='rapport';
% social_dim{5}='performance';
% %corresponding values
% soc_choice=[-1 -0.67 -0.34 0 0.32 0.65 0.98];
% N_cho=length(soc_choice);
% %sequence to analyse
% seq_to_analyse=1:N_seq;
% N_seq_toan=length(seq_to_analyse);
% %N bined continuous annotation values
% N=7501;
% 
% data_aro=zeros(Nr,N,N_seq_toan,3);
% data_val=zeros(Nr,N,N_seq_toan,3);
% data_soc=zeros(Nr,N_soc_dim,N_seq_toan,2);
% cpt_seq=1;
% for seq=seq_to_analyse,
%     disp(['Processing sequence n°' num2str(seq)])
%     cpt=0;
%     for rater=1:8,
%         if ~isempty(data_rater{rater}),
%             cpt=cpt+1;
%             %get data of a rater and a sequence
%             data_aro(cpt,:,cpt_seq,1)=data_rater{rater}.save_binrataro{seq};
%             ind=find(isnan(data_aro(cpt,:,cpt_seq,1)));ind2=find(diff(ind)>1);
%             if ~isempty(ind2),
%                 data_aro(cpt,1:ind2,cpt_seq,1)=0;
%                 data_aro(cpt,ind(ind2+1):N,cpt_seq,1)=repmat(data_aro(cpt,ind(ind2+1)-1,cpt_seq,1),1,N-ind(ind2+1)+1);
%             else
%                 data_aro(cpt,1:ind(end),cpt_seq,1)=0;
%             end
%             %mean-centering
%             data_aro(cpt,:,cpt_seq,2)=data_aro(cpt,:,cpt_seq,1)-repmat(mean(data_aro(cpt,:,cpt_seq,1)),1,N);
%             
%             data_val(cpt,:,cpt_seq,1)=data_rater{rater}.save_binratval{seq};
%             ind=find(isnan(data_val(cpt,:,cpt_seq,1)));ind2=find(diff(ind)>1);
%             if ~isempty(ind2),
%                 data_val(cpt,1:ind2,cpt_seq,1)=0;
%                 data_val(cpt,ind(ind2+1):N,cpt_seq,1)=repmat(data_val(cpt,ind(ind2+1)-1,cpt_seq,1),1,N-ind(ind2+1)+1);
%             else
%                 data_val(cpt,1:ind(end),cpt_seq,1)=0;
%             end
%             data_val(cpt,:,cpt_seq,2)=data_val(cpt,:,cpt_seq,1)-repmat(mean(data_val(cpt,:,cpt_seq,1)),1,N);
%             
%             %convert social annotation values
%             data_soc(cpt,:,cpt_seq,1)=(data_rater{rater}.save_socrat(:,seq))';
%             for i=1:N_soc_dim,
%                 switch data_soc(cpt,i,cpt_seq,1),
%                     case soc_choice(1),
%                         data_soc(cpt,i,cpt_seq,1)=1;
%                     case soc_choice(2),
%                         data_soc(cpt,i,cpt_seq,1)=2;
%                     case soc_choice(3),
%                         data_soc(cpt,i,cpt_seq,1)=3;
%                     case soc_choice(4),
%                         data_soc(cpt,i,cpt_seq,1)=4;
%                     case -0.01,
%                         data_soc(cpt,i,cpt_seq,1)=4;
%                     case soc_choice(5),
%                         data_soc(cpt,i,cpt_seq,1)=5;
%                     case soc_choice(6),
%                         data_soc(cpt,i,cpt_seq,1)=6;
%                     case soc_choice(7),
%                         data_soc(cpt,i,cpt_seq,1)=7;
%                     case 1,
%                         data_soc(cpt,i,cpt_seq,1)=7;
%                     otherwise
%                 end
%             end
%         end
%     end
%     
%     delays=NaN*ones(Nr,Nr); del_smp=-max_sdelay*Fe:max_sdelay*Fe;
%     %loop on the annotators to perform sync of arousal
%     for f=list,
%         %trace of annotator f
%         rater_ref=data_aro(f,max_sdelay*Fe+1:N-(max_sdelay*Fe+1),cpt_seq,2);
%         N_valref=length(rater_ref);
%         %loop on traces from others annotators
%         for foth=list(logical(list~=f)),
%             %loop on delays to test with MSE criterion
%             val=zeros(1,2*max_sdelay*Fe+1);
%             for del=del_smp,
%                 ind=-del+max_sdelay*Fe+1:-del+max_sdelay*Fe+N_valref;
%                 meanval=mean([rater_ref;data_aro(foth,ind,cpt_seq,2)]);
%                 val(del+max_sdelay*Fe+1)=mean((rater_ref-meanval).^2);
%             end
%             [tmp, ind_del]=min(val);
%             %minimum global?
%             if ind_del~=1 && ind_del~=length(del_smp),
%                 delays(f,foth)=del_smp(ind_del);
%             else%otherwise do not synch
%                 delays(f,foth)=0;
%             end
%         end
%     end
%     %compute mean on delays
%     mean_delays=round(nanmean(delays));
%     %loop on the annotators to sync their trace
%     for f=list,
%         if mean_delays(f)>0,
%             data_aro(f,:,cpt_seq,3)=[repmat(data_aro(f,1,cpt_seq,2),1,mean_delays(f)) data_aro(f,1:N-mean_delays(f),cpt_seq,2)];
%         elseif mean_delays(f)<0
%             data_aro(f,:,cpt_seq,3)=[data_aro(f,1:N+mean_delays(f),cpt_seq,2) repmat(data_aro(f,N+mean_delays(f),cpt_seq,2),1,-mean_delays(f))];
%         else
%             data_aro(f,:,cpt_seq,3)=data_aro(f,:,cpt_seq,2);
%         end
%     end
%     
%     delays=NaN*ones(Nr,Nr); del_smp=-max_sdelay*Fe:max_sdelay*Fe;
%     %loop on the annotators to perform sync of valence
%     for f=list,
%         %trace of annotator f
%         rater_ref=data_val(f,max_sdelay*Fe+1:N-(max_sdelay*Fe+1),cpt_seq,2);
%         N_valref=length(rater_ref);
%         %loop on traces from others annotators
%         for foth=list(logical(list~=f)),
%             %loop on delays to test with MSE criterion
%             val=zeros(1,2*max_sdelay*Fe+1);
%             for del=del_smp,
%                 ind=-del+max_sdelay*Fe+1:-del+max_sdelay*Fe+N_valref;
%                 meanval=mean([rater_ref;data_val(foth,ind,cpt_seq,2)]);
%                 val(del+max_sdelay*Fe+1)=mean((rater_ref-meanval).^2);
%             end
%             [tmp, ind_del]=min(val);
%             %minimum global?
%             if ind_del~=1 && ind_del~=length(del_smp),
%                 delays(f,foth)=del_smp(ind_del);
%             else
%                 delays(f,foth)=0;
%             end
%         end
%     end
%     %compute mean on delays
%     mean_delays=round(nanmean(delays));
%     %loop on the annotators to sync their trace
%     for f=list,
%         if mean_delays(f)>0,
%             data_val(f,:,cpt_seq,3)=[repmat(data_val(f,1,cpt_seq,2),1,mean_delays(f)) data_val(f,1:N-mean_delays(f),cpt_seq,2)];
%         elseif mean_delays(f)<0
%             data_val(f,:,cpt_seq,3)=[data_val(f,1:N+mean_delays(f),cpt_seq,2) repmat(data_val(f,N+mean_delays(f),cpt_seq,2),1,-mean_delays(f))];
%         else
%             data_val(f,:,cpt_seq,3)=data_val(f,:,cpt_seq,2);
%         end
%     end    
%     cpt_seq=cpt_seq+1;    
% end
% %mean-centering of social annotations
% for rater=1:Nr,
%     for dim=1:N_soc_dim,
%         valtmp=zeros(1,N_seq_toan);
%         valtmp(:)=data_soc(rater,dim,:,1);
%         valtmp=valtmp-repmat(mean(valtmp),1,N_seq_toan);
%         data_soc(rater,dim,:,2)=round(ceil(N_cho/2)+fix(N_cho/2)*valtmp/max(abs(valtmp)));
%     end
% end
% 
% %% analysis and save of continuous ratings in text file
% timecode=0:1/Fe:300;
% participant_number=[13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 30 32 34 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 62 63 64 65];
% 
% mce_aro=nan*ones(Nr,N_seq_toan,3);mce_val=nan*ones(Nr,N_seq_toan,3);
% alpha_aro=nan*ones(N_seq_toan,3);alpha_val=nan*ones(N_seq_toan,3);
% N_pos_aro=nan*ones(N_seq_toan,3);N_pos_val=nan*ones(N_seq_toan,3);
% N_neg_aro=nan*ones(N_seq_toan,3);N_neg_val=nan*ones(N_seq_toan,3);
% cor_coe_aro=nan*ones(N_seq_toan,3);cor_coe_val=nan*ones(N_seq_toan,3);
% 
% for seq=1:N_seq_toan,
%     for condition=1:3,
%         data_aro_grd=mean(data_aro(:,:,seq,condition));
%         data_val_grd=mean(data_val(:,:,seq,condition));
%         
%         N_pos_aro(seq,condition)=length(find(data_aro_grd>=0));
%         N_neg_aro(seq,condition)=length(find(data_aro_grd<0));
%         N_pos_val(seq,condition)=length(find(data_val_grd>=0));
%         N_neg_val(seq,condition)=length(find(data_val_grd<0));
%         
%         for rater=1:Nr,
%             mce_aro(rater,seq,condition)=nanmean((data_aro(rater,:,seq,condition)-data_aro_grd).^2);
%             mce_val(rater,seq,condition)=nanmean((data_aro(rater,:,seq,condition)-data_val_grd).^2);
%         end
%         
%         alpha_aro(seq,condition)=cronbach(data_aro(:,:,seq,condition));
%         alpha_val(seq,condition)=cronbach(data_val(:,:,seq,condition));
%         
%         list=1:Nr;
%         xcor_rst=NaN*ones(Nr,Nr);
%         %loop on the annotators
%         for f=list,
%             %loop on traces from others annotators
%             for foth=list(logical(list~=f)),
%                 val_tmp=corrcoef(data_aro(f,:,seq,condition),data_aro(foth,:,seq,condition));
%                 xcor_rst(f,foth)=val_tmp(2,1);
%             end
%         end
%         cor_coe_aro(seq,condition)=mean(nanmean(xcor_rst,2));
%         
%         xcor_rst=NaN*ones(Nr,Nr);
%         %loop on the annotators
%         for f=list,
%             %loop on traces from others annotators
%             for foth=list(logical(list~=f)),
%                 val_tmp=corrcoef(data_val(f,:,seq,condition),data_val(foth,:,seq,condition));
%                 xcor_rst(f,foth)=val_tmp(2,1);
%             end
%         end
%         cor_coe_val(seq,condition)=mean(nanmean(xcor_rst,2));
% 
% %         %save ratings in text file
% %         switch condition
% %             case 1,
% %                 %arousal_raw, 
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_arousal_raw.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;FM1 ;FM2 ;FM3 ;FF1 ;FF2 ;FF3\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f\n',timecode(i),data_aro(:,i,seq,1)');
% %                 end
% %                 fclose(fid);
% %                 %valence_raw
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_valence_raw.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;FM1 ;FM2 ;FM3 ;FF1 ;FF2 ;FF3\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f\n',timecode(i),data_val(:,i,seq,1)');
% %                 end
% %                 fclose(fid);
% %                 
% %                 %arousal_gndtrh_raw, 
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_arousal_gndtrh_raw.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;mean value (raw)\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f\n',timecode(i),data_aro_grd(i));
% %                 end
% %                 fclose(fid);
% %                 %valence_gndtrh_raw
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_valence_gndtrh_raw.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;mean value (raw)\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f\n',timecode(i),data_val_grd(i));
% %                 end
% %                 fclose(fid);
% %             case 2,
% %                 %arousal_gndtrh_zm,
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_arousal_gndtrh_zm.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;mean value (zero-mean)\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f\n',timecode(i),data_aro_grd(i));
% %                 end
% %                 fclose(fid);
% %                 %valence_gndtrh_zm
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_valence_gndtrh_zm.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;mean value (zero-mean)\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f\n',timecode(i),data_val_grd(i));
% %                 end
% %                 fclose(fid);
% %             case 3,
% %                 %arousal_gndtrh_zms,
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_arousal_gndtrh_zms.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;mean value (zero-mean+sync)\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f\n',timecode(i),data_aro_grd(i));
% %                 end
% %                 fclose(fid);
% %                 %valence_gndtrh_zms
% %                 filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Emotion_dim_valence_gndtrh_zms.csv'];
% %                 fid=fopen([save_pathd filename],'wt');
% %                 fprintf(fid,'time;mean value (zero-mean+sync)\n');
% %                 for i=1:7501,
% %                     fprintf(fid,'%.2f;%.2f\n',timecode(i),data_val_grd(i));
% %                 end
% %                 fclose(fid);
% %         end
%     end
% end
% %%
% conditions=cell(1,3);
% conditions{1}='Raw';
% conditions{2}='Mean-centered';
% conditions{3}='Synchronised on mean-centered, mean-centered';
% 
% for cond=1:3,
%     disp(' ')
%     disp(['---- ' conditions{cond} ' ----'])
%     disp(' ')
%     disp('- Arousal -')
%     tmpval1=nansum(N_pos_aro(:,cond));tmpval2=nansum(N_neg_aro(:,cond));
%     disp(['%pos = ' num2str(round(1000*tmpval1/(tmpval1+tmpval2))/10)])
%     disp(['MSE = ' num2str(round(mean(mean(mce_aro(:,:,cond)))*1e4)/1e4) '; corr = ' num2str(mean(cor_coe_aro(:,cond))) ', alpha = ' num2str(round(nanmean(alpha_aro(:,cond))*1e2)/1e2)])
%     disp(' ')
%     disp('- Valence -')
%     tmpval1=nansum(N_pos_val(:,cond));tmpval2=nansum(N_neg_val(:,cond));
%     disp(['%pos = ' num2str(round(1000*tmpval1/(tmpval1+tmpval2))/10)])
%     disp(['MSE = ' num2str(round(mean(mean(mce_val(:,:,cond)))*1e4)/1e4) '; corr = ' num2str(mean(cor_coe_val(:,cond))) ', alpha = ' num2str(round(nanmean(alpha_val(:,cond))*1e2)/1e2)])
% end
% 
% %% analysis and save of social ratings in text file
% soc_ratings=NaN*ones(Nr,N_seq_toan,N_soc_dim);
% cpt=0;
% for rater=1:8,
%     if ~isempty(data_rater{rater}),
%         cpt=cpt+1;
%         data=data_rater{rater}.save_socrat;
%         for seq=1:N_seq_toan,
%             for i=1:N_soc_dim,
%                 switch data(i,seq_to_analyse(seq)),
%                     case soc_choice(1),
%                         soc_ratings(cpt,seq,i)=1;
%                     case soc_choice(2),
%                         soc_ratings(cpt,seq,i)=2;
%                     case soc_choice(3),
%                         soc_ratings(cpt,seq,i)=3;
%                     case soc_choice(4),
%                         soc_ratings(cpt,seq,i)=4;
%                     case -0.01,
%                         soc_ratings(cpt,seq,i)=4;
%                     case soc_choice(5),
%                         soc_ratings(cpt,seq,i)=5;
%                     case soc_choice(6),
%                         soc_ratings(cpt,seq,i)=6;
%                     case soc_choice(7),
%                         soc_ratings(cpt,seq,i)=7;
%                     case 1,
%                         soc_ratings(cpt,seq,i)=7;
%                     otherwise
%                 end
%             end
%         end
%     end
% end
% 
% soc_ratings_zm=NaN*ones(Nr,N_seq_toan,N_soc_dim);
% for rater=1:Nr,
%     for dim=1:N_soc_dim,
%         soc_ratings_zm(rater,:,dim)=soc_ratings(rater,:,dim)-repmat(mean(soc_ratings(rater,:,dim)),1,N_seq_toan);
%         soc_ratings_zm(rater,:,dim)=round(ceil(N_cho/2)+fix(N_cho/2)*soc_ratings_zm(rater,:,dim)/max(abs(soc_ratings_zm(rater,:,dim))));
%     end
% end
% 
% for dim=1:N_soc_dim,
%     N_pos=length(find(soc_ratings(:,seq_to_analyse,dim)>4));
%     N_neg=length(find(soc_ratings(:,seq_to_analyse,dim)<4));
%     disp([social_dim{dim} ', %neg = ' num2str(round(1000*N_neg/(Nr*N_seq_toan))/10)])
%     disp([social_dim{dim} ', %pos = ' num2str(round(1000*N_pos/(Nr*N_seq_toan))/10)])
% end
% 
% %linear weigthed fleiss' kappa
% weights=zeros(N_cho,N_cho);
% for i=1:N_cho,
%     for j=1:N_cho,        
%         weights(i,j)=(N_cho-1-abs(i-j))/(N_cho-1);
%     end
% end
% list=zeros(Nr*(Nr-1)/2,2);cpt=0;
% for i=1:Nr-1,
%     for j=1+i:Nr,
%         cpt=cpt+1;
%         list(cpt,:)=[i j];
%     end
% end
% N_list=length(list);
% 
% kappa=zeros(1,N_soc_dim);
% for dim=1:N_soc_dim,    
%     PE=zeros(1,Nr*(Nr-1)/2);PO=zeros(1,Nr*(Nr-1)/2);
%     for line=1:N_list,
%         r1=list(line,1);r2=list(line,2);
%         kappa_mat=zeros(N_cho,N_cho);
%         for seq=seq_to_analyse,
%             kappa_mat(soc_ratings(r2,seq,dim),soc_ratings(r1,seq,dim))=kappa_mat(soc_ratings(r2,seq,dim),soc_ratings(r1,seq,dim))+1;
%         end
%         PO(line)=1/N_seq_toan*sum(sum(kappa_mat.*weights));
%         RI=zeros(1,N_cho);CJ=zeros(1,N_cho);
%         for cho=1:N_cho,
%             RI(cho)=sum(kappa_mat(:,cho));
%             CJ(cho)=sum(kappa_mat(cho,:));
%         end
%         valtmp=0;
%         for i=1:N_cho,
%             for j=1:N_cho,
%                 valtmp=valtmp+weights(i,j)*RI(i)*CJ(j);
%             end
%         end
%         PE(line)=1/(N_seq_toan^2)*valtmp;
%     end
%     kappa(dim)=(mean(PO)-mean(PE))/(1-mean(PE));
% end
% 
% soc_ratings_zm=NaN*ones(Nr,N_seq_toan,N_soc_dim);
% for rater=1:Nr,
%     for dim=1:N_soc_dim,
%         soc_ratings_zm(rater,seq_to_analyse,dim)=soc_ratings(rater,seq_to_analyse,dim)-repmat(mean(soc_ratings(rater,seq_to_analyse,dim)),1,N_seq_toan);
%         soc_ratings_zm(rater,seq_to_analyse,dim)=round(ceil(N_cho/2)+fix(N_cho/2)*soc_ratings_zm(rater,seq_to_analyse,dim)/max(abs(soc_ratings_zm(rater,seq_to_analyse,dim))));
%     end
% end
% for dim=1:N_soc_dim,
%     N_pos=length(find(soc_ratings_zm(:,seq_to_analyse,dim)>4));
%     N_neg=length(find(soc_ratings_zm(:,seq_to_analyse,dim)<4));
%     disp([social_dim{dim} ', %neg = ' num2str(round(1000*N_neg/(Nr*N_seq_toan))/10)])
%     disp([social_dim{dim} ', %pos = ' num2str(round(1000*N_pos/(Nr*N_seq_toan))/10)])
% end
% 
% 
% kappa_zm=zeros(1,N_soc_dim);
% for dim=1:N_soc_dim,    
%     PE=zeros(1,Nr*(Nr-1)/2);PO=zeros(1,Nr*(Nr-1)/2);
%     for line=1:N_list,
%         r1=list(line,1);r2=list(line,2);
%         kappa_mat=zeros(N_cho,N_cho);
%         for seq=seq_to_analyse,
%             kappa_mat(soc_ratings_zm(r2,seq,dim),soc_ratings_zm(r1,seq,dim))=kappa_mat(soc_ratings_zm(r2,seq,dim),soc_ratings_zm(r1,seq,dim))+1;
%         end
% %         PO(line)=1/N_seq_toan*sum(sum(kappa_mat.*weights));
%         PO(line)=1/N_seq_toan*sum(sum(kappa_mat.*weights));
%         RI=zeros(1,N_cho);CJ=zeros(1,N_cho);
%         for cho=1:N_cho,
%             RI(cho)=sum(kappa_mat(:,cho));
%             CJ(cho)=sum(kappa_mat(cho,:));
%         end
%         valtmp=0;
%         for i=1:N_cho,
%             for j=1:N_cho,
%                 valtmp=valtmp+weights(i,j)*RI(i)*CJ(j);
%             end
%         end
%         PE(line)=1/(N_seq_toan^2)*valtmp;
%     end
%     kappa_zm(dim)=(mean(PO)-mean(PE))/(1-mean(PE));
% end
% 
% soc_ratings_zs=NaN*ones(Nr,N_seq_toan,N_soc_dim);
% for rater=1:Nr,
%     for dim=1:N_soc_dim,
%         soc_ratings_zs(rater,seq_to_analyse,dim)=soc_ratings(rater,seq_to_analyse,dim)-repmat(mean(soc_ratings(rater,seq_to_analyse,dim)),1,N_seq_toan);
%         soc_ratings_zs(rater,seq_to_analyse,dim)=soc_ratings_zs(rater,seq_to_analyse,dim)./repmat(std(soc_ratings(rater,seq_to_analyse,dim)),1,N_seq_toan);
%         soc_ratings_zs(rater,seq_to_analyse,dim)=round(ceil(N_cho/2)+fix(N_cho/2)*soc_ratings_zs(rater,seq_to_analyse,dim)/max(abs(soc_ratings_zs(rater,seq_to_analyse,dim))));
%     end
% end
% 
% kappa_zs=zeros(1,N_soc_dim);
% for dim=1:N_soc_dim,    
%     PE=zeros(1,Nr*(Nr-1)/2);PO=zeros(1,Nr*(Nr-1)/2);
%     for line=1:N_list,
%         r1=list(line,1);r2=list(line,2);
%         kappa_mat=zeros(N_cho,N_cho);
%         for seq=seq_to_analyse,
%             kappa_mat(soc_ratings_zs(r2,seq,dim),soc_ratings_zs(r1,seq,dim))=kappa_mat(soc_ratings_zs(r2,seq,dim),soc_ratings_zs(r1,seq,dim))+1;
%         end
% %         PO(line)=1/N_seq_toan*sum(sum(kappa_mat.*weights));
%         PO(line)=1/N_seq_toan*sum(sum(kappa_mat.*weights));
%         RI=zeros(1,N_cho);CJ=zeros(1,N_cho);
%         for cho=1:N_cho,
%             RI(cho)=sum(kappa_mat(:,cho));
%             CJ(cho)=sum(kappa_mat(cho,:));
%         end
%         valtmp=0;
%         for i=1:N_cho,
%             for j=1:N_cho,
%                 valtmp=valtmp+weights(i,j)*RI(i)*CJ(j);
%             end
%         end
%         PE(line)=1/(N_seq_toan^2)*valtmp;
%     end
%     kappa_zs(dim)=(mean(PO)-mean(PE))/(1-mean(PE));
% end
% 
% % %save raw
% % for seq=1:N_seq_toan,
% %     for soc_dim=1:5,
% %         filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Social_dim_' social_dim{soc_dim} '_raw.csv'];
% %         fid=fopen([save_pathds filename],'wt');
% %         fprintf(fid,'FM1;FM2;FM3;FF1;FF2;FF3\n');
% %         fprintf(fid,'%d  ;%d  ;%d  ;%d  ;%d  ;%d  \n',soc_ratings(:,seq,soc_dim)');
% %         fclose(fid);
% %     end
% % end
% % %save raw groundtruth
% % for seq=1:N_seq_toan,
% %     filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Social_gndtrh_raw.csv'];
% %     values=zeros(1,5);
% %     for soc_dim=1:5,
% %         values(soc_dim)=mean(soc_ratings(:,seq,soc_dim));
% %     end
% %     fid=fopen([save_pathds filename],'wt');
% %     fprintf(fid,'agre;domi;enga;perf;rapp\n');
% %     fprintf(fid,'%.2f;%.2f;%.2f;%.2f;%.2f\n',values(1),values(3),values(2),values(5),values(4));
% %     fclose(fid);
% % end
% % %save zero-mean groundtruth
% % for seq=1:N_seq_toan,
% %     filename=['P' num2str(participant_number(seq_to_analyse(seq))) '_Social_gndtrh_zm.csv'];
% %     values=zeros(1,5);
% %     for soc_dim=1:5,
% %         values(soc_dim)=mean(soc_ratings_zm(:,seq,soc_dim));
% %     end
% %     fid=fopen([save_pathds filename],'wt');
% %     fprintf(fid,'agre;domi;enga;perf;rapp\n');
% %     fprintf(fid,'%.2f;%.2f;%.2f;%.2f;%.2f\n',values(1),values(3),values(2),values(5),values(4));
% %     fclose(fid);
% % end