%对dax里面的xml数据进行处理
    clear ;
    fileName = "CyberShake_30.xml";
    isDraw = 1;
    dom = xmlread(fileName);
    nodes = dom.getElementsByTagName('adag');

    %得到job、child的数目
    node = nodes.item(0);%第一个节点
    jobs = node.getElementsByTagName('job');
    jobLen = (jobs.getLength);
    children = node.getElementsByTagName('child');
    childNum = children.getLength;


    %------------------------Job的数据处理-----------------------------------%
    %构造job的结构体数组
    structSingleJob = struct('jobId',[],'inputSizeArray',{},'inputLen',0,'outputSizeArray',{},'outputLen',0,'runTime',[]);%结构体类型
    structJobs = repmat(structSingleJob,[1 jobLen]);%生成结构体数组
    for i=0:jobLen-1
        %初始化
        id = string.empty();
        inputSizeArray = string.empty();
        outputSizeArray = string.empty();

        %单个job
        jobSingle = jobs.item(i);
        id = char(jobSingle.getAttribute('id'));
        structJobs(i+1).jobId = id;
        runTime = char(jobSingle.getAttribute('runtime'));
        structJobs(i+1).runTime = runTime;



        %从job进入uses
        jobI = jobs.item(i);
        uses = jobI.getElementsByTagName('uses');
        usesNum = uses.getLength; 

        %遍历uses
        inputSizes = string.empty();
        outputSizes = string.empty();
        %进行初始化，默认为0
        structJobs(i+1).inputLen = 0;
        structJobs(i+1).outputLen = 0;
        for j=0:usesNum-1
            usesI = uses.item(j);
            inputOrOutput = (char(usesI.getAttribute('link')));
            if strcmp(inputOrOutput,'input') == 1



                structJobs(i+1).inputLen = structJobs(i+1).inputLen + 1;

                inputSize = (char(usesI.getAttribute('size')));
                inputSizes  = [inputSizes,inputSize];

            else
                structJobs(i+1).outputLen = structJobs(i+1).outputLen + 1;

                outputSize = (char(usesI.getAttribute('size')));
                outputSizes  = [outputSizes,outputSize];

            end

        end
        structJobs(i+1).inputSizeArray = inputSizes;
        structJobs(i+1).outputSizeArray = outputSizes;
    end


    %------------------------children-parents的数据处理-----------------------------------%
    %构造child-parent的结构体数组
    structSinglechild = struct('childRef',[],'parentIdArray',{},'parentLen',0);%结构体类型
    structchildren = repmat(structSinglechild,[1 childNum]);%生成结构体数组
    for i=0:childNum-1
        %初始化
        ref = string.empty();

        parentArray = string.empty();


        %单个child
        childSingle = children.item(i);
        ref = char(childSingle.getAttribute('ref'));
        structchildren(i+1).childRef = ref;

    %     disp('child');
    %     disp(structchildren(i+1).childRef);


        %从child进入parent
        childI = children.item(i);
        parents = childI.getElementsByTagName('parent');
        parentLen = parents.getLength; 

        %遍历parents
        parentIdArrays = string.empty();
        structchildren(i+1).parentLen = 0;
        for j=0:parentLen-1
            parentI = parents.item(j);
            parentIdArray = (char( parentI.getAttribute('ref')));

            structchildren(i+1).parentLen = structchildren(i+1).parentLen + 1;
    %         disp('parent');
            parentIdArray = (char(parentI.getAttribute('ref')));
            parentIdArrays  = [parentIdArrays,parentIdArray];

        end
    %     disp('parent');
    %     disp(parentIdArrays);

        structchildren(i+1).parentIdArray = parentIdArrays;

    end
    disp('数据处理完成!');



    %%%%%%%%------------------数字化的处理------------------------------------------%%%%%%%%
    %%%%%%%%------------------1.特别是ID,统一到从1开始------------------------------%%%%%%%%
    %%%%%%%%------------------2.intput,output,size等数字化，但都是double------------%%%%%%%%


    %------------------------对jobs进行处理，将数字字符串相应的数据转为数字---------------%
    structSinglejobLeneral = struct('jobId',[],'inputSizeArray',[],'inputLen',0,'outputSizeArray',[],'outputLen',0,'runTime',[]);%结构体类型
    structJobsNumeral = repmat(structSingleJob,[1 jobLen]);%生成结构体数组

    structJobsFirstjobId = structJobs(1).jobId;
    structJobsFirstjobId = strrep(structJobsFirstjobId,'I','0');
    structJobsFirstjobId = strrep(structJobsFirstjobId,'D','0');  
    structJobsFirstjobIdValue = int32((str2double(structJobsFirstjobId)));
    isIdValueOne = (structJobsFirstjobIdValue == 1); %做一个标记是否Id从1开始


    for i=1:jobLen
        %jobId的数字化处理
        stringTemp = structJobs(i).jobId;
        stringTemp = strrep(stringTemp,'I','0');
        stringTemp = strrep(stringTemp,'D','0');
        if isIdValueOne~=1
            structJobsNumeral(i).jobId = ((str2double(stringTemp))+1);
        else
            structJobsNumeral(i).jobId = ((str2double(stringTemp)));
        end

        structJobsNumeral(i).inputLen = structJobs(i).inputLen;
        structJobsNumeral(i).outputLen = structJobs(i).outputLen;
        structJobsNumeral(i).runTime = ((str2double(structJobs(i).runTime)));

        for j=1:structJobs(i).inputLen
            %inputSizeArray的数字化 但仍是double类型，不是int类型
            stringTemp = structJobs(i).inputSizeArray(j);
            structJobsNumeral(i).inputSizeArray(j) = ((str2double(stringTemp)));
        end

        for j=1:structJobs(i).outputLen
            %inputSizeArray的数字化 但仍是double类型，不是int类型
            stringTemp = structJobs(i).outputSizeArray(j);
            structJobsNumeral(i).outputSizeArray(j) = ((str2double(stringTemp)));
        end
    end






    %------------------------对child-parent进行处理，将数字字符串相应的数据转为数字---------------%
    %------------------------对child-parent进行处理，再转化成jobLen个个体的结构体---------------%
    structSinglechildNumeral = struct('childRef',[],'parentIdArray',[],'parentLen',0);%结构体类型
    structchildrenLeneral = repmat(structSinglechildNumeral,[1 childNum]);%生成结构体数组

    for i=1:childNum
        stringTemp = structchildren(i).childRef;
        stringTemp = strrep(stringTemp,'I','0');
        stringTemp = strrep(stringTemp,'D','0');  
        if isIdValueOne~=1
            structchildrenLeneral(i).childRef = ((str2double(stringTemp))+1);
        else
            structchildrenLeneral(i).childRef = ((str2double(stringTemp)));
        end

        for j=1:structchildren(i).parentLen
            %parentId的数字化 但仍是double类型，不是int类型
            stringTemp = structchildren(i).parentIdArray(j);
            stringTemp = strrep(stringTemp,'I','0');
            stringTemp = strrep(stringTemp,'D','0');  
            if isIdValueOne~=1
                structchildrenLeneral(i).parentIdArray(j) = ((str2double(stringTemp))+1);
            else
                structchildrenLeneral(i).parentIdArray(j) = ((str2double(stringTemp)));
            end

        end
        structchildrenLeneral(i).parentLen = structchildren(i).parentLen;
    end

    %初始化 构造从1-jobLen的结构体数组
    structchildrenLeneral2 = repmat(structSinglechildNumeral,[1 jobLen]);%生成结构体数组
    for i=1:jobLen
        structchildrenLeneral2(i).childRef = i;
    %     structchildrenLeneral2(i).parentIdArray = -1;
        structchildrenLeneral2(i).parentLen = 0;
    end

    for i=1:childNum
        structchildrenLeneral2(int32(structchildrenLeneral(i).childRef)) = structchildrenLeneral(i);
    end



    %-------------------------构造一个parent-child的数字数据结构----------------------------%
    structSingleparentLeneral2 = struct('parentRef',[],'childrenIdArray',[],'childrenLen',0);%结构体类型
    structParentsNumeral2 = repmat(structSingleparentLeneral2,[1 jobLen]);%生成结构体数组
    %初始化
    for i=1:jobLen
        structParentsNumeral2(i).parentRef = i;
    %     structParentsNumeral2(i).childrenIdArray = -1;
        structParentsNumeral2(i).childrenLen = 0;
    end

    for i=1:childNum
        for j=1:structchildrenLeneral(i).parentLen
            structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenIdArray = [structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenIdArray, (structchildrenLeneral(i).childRef)];
            structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenLen = structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenLen + 1;
            structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).parentRef = structchildrenLeneral(i).parentIdArray(j);
        end
    end

    disp('数据数字化完成！');






    %--------------------------画图---------------------------------------------%

    %构造邻接矩阵，为了将jobId对应邻接矩阵，有些数据集的jobId的值 ---->Matrix

    JobIDAdjacencyMatrix = zeros(jobLen,jobLen);

    for i=1:childNum
        for j=1:structchildrenLeneral(i).parentLen  
            JobIDAdjacencyMatrix(int32((structchildrenLeneral(i).parentIdArray(j))),int32(structchildrenLeneral(i).childRef)) = 1;
        end
    end
    %画图
    if isDraw == 1
        G = digraph(JobIDAdjacencyMatrix);
        G.plot();
    else
        
    end













    %------------------------------测试调度--------------------------------%

    taskNum = jobLen;

    structSingleTask = struct('taskId',[],'inputSizeArray',[],'outputSizeArray',[],'childIdArray',[],'childIdArrayLen',0,'parentIdArray',[],'parentIdArrayLen',0,'inputLen',0,'outputLen',0,'taskLayer',0,'runTime',0);%结构体类型
    structTasksBase = repmat(structSingleTask,[1 taskNum]);%生成结构体数组





    %---------------------层次遍历---------------------------------------%ta


    for i=1:taskNum
        structTasksBase(i).taskId = structJobsNumeral(i).jobId;
        structTasksBase(i).childIdArray = structParentsNumeral2(i).childrenIdArray;
        structTasksBase(i).childIdArrayLen = structParentsNumeral2(i).childrenLen;
        structTasksBase(i).parentIdArray = structchildrenLeneral2(i).parentIdArray;
        structTasksBase(i).parentIdArrayLen = structchildrenLeneral2(i).parentLen; 
        structTasksBase(i).inputSizeArray = structJobsNumeral(i).inputSizeArray;
        structTasksBase(i).inputLen = structJobsNumeral(i).inputLen;
        structTasksBase(i).outputSizeArray = structJobsNumeral(i).outputSizeArray;
        structTasksBase(i).outputLen = structJobsNumeral(i).outputLen;
        structTasksBase(i).runTime = structJobsNumeral(i).runTime;
    end


    %-----1.找到所有祖先节点---------------%
    ancestorTaskArray = [];
    ancestorTaskArrayLen = 0;

    %只需遍历structchilid就够了，找到child没有parent的节点
    for i=1:taskNum
        if structchildrenLeneral2(i).parentLen == 0
            ancestorTaskArrayLen = ancestorTaskArrayLen + 1;
            ancestorTaskArray = [ancestorTaskArray,structchildrenLeneral2(i).childRef];
        end
    end



    %专门保存层的数目
    structTaskLayer = struct('taskId',0,'maxLayer',0,'layers',[]);
    structTaskLayerAll = repmat(structTaskLayer,[1 taskNum]);%生成结构体数组


    for i=1:taskNum
        structTaskLayerAll(i).taskId = i;
    end

    %单独处理第一层和第二层
    for i=1:ancestorTaskArrayLen
        structTaskLayerAll((ancestorTaskArray(i))).layers = [structTaskLayerAll(int32(ancestorTaskArray(i))).layers, 1];
        structTaskLayerAll((ancestorTaskArray(i))).maxLayer = max( structTaskLayerAll(int32(ancestorTaskArray(i))).layers);
        for j=1:structTasksBase(int32(ancestorTaskArray(i))).childIdArrayLen
            structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).layers = [structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).layers,2];
            structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).maxLayer = max(structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).layers);
        end
    end


    %通过实验发现，因为节点序号是从小到大，所以从小开始遍历可以使得一次遍历得到所有层数，
    %但是如果从大到小则不行，于是循环了多次的操作，才得到正确答案，所以设置为上下两次迭代的maxLayer之和不变，则停止迭代

    currentMaxLayerSum = 0;
    lastMaxLayerSum = -1;
    layerMax = 1;%统计共有多少层
    while(currentMaxLayerSum ~= lastMaxLayerSum)%还得再看看
        lastMaxLayerSum = currentMaxLayerSum;
        currentMaxLayerSum = 0;
        for i=1:1:taskNum
            if ismember(i,ancestorTaskArray) == 1

                %如果是最 祖先节点，不必再重新计算
            else
                if structTaskLayerAll(i).maxLayer == 0   %如果本身都没有值，那么它的子代就不用计算了
                    continue;
                else
                    for j=1:structTasksBase(i).childIdArrayLen
                        structTaskLayerAll(structTasksBase(i).childIdArray(j)).layers = [structTaskLayerAll(structTasksBase(i).childIdArray(j)).layers , structTaskLayerAll(i).maxLayer+1];
                        structTaskLayerAll(structTasksBase(i).childIdArray(j)).maxLayer = max(structTaskLayerAll(structTasksBase(i).childIdArray(j)).layers);
                        if layerMax < structTaskLayerAll(structTasksBase(i).childIdArray(j)).maxLayer
                            layerMax = structTaskLayerAll(structTasksBase(i).childIdArray(j)).maxLayer;
                        end
                    end
                end
            end
            currentMaxLayerSum = currentMaxLayerSum + structTaskLayerAll(i).maxLayer;
        end  
    end
    disp('层数计算完成!');

    for i=1:taskNum
        structTasksBase(i).taskLayer = structTaskLayerAll(i).maxLayer;
    end
    % 生成一个结构体，用于存储每一层有哪些task
    structLayer = struct('layerIndex',0,'taskArray',[]);
    structLayers = repmat(structLayer,[1 layerMax]);%生成结构体数组

    for i=1:layerMax
        structLayers(i).layerIndex = i;
    end
    for i=1:taskNum
        structLayers(structTasksBase(i).taskLayer).taskArray = [structLayers(structTasksBase(i).taskLayer).taskArray,structTasksBase(i).taskId];
    end

    
    
    %设置每个task的deadline,根据runtime来设置
%     minDeadLine = 1;
%     maxDeadLine = 3;
%     minRunTime = inf;
%     maxRunTime = -inf;
%     for i=1:jobLen
%         if structTasksBase(i).runTime < minRunTime
%             minRunTime = structTasksBase(i).runTime;
%         end
%         if structTasksBase(i).runTime > maxRunTime
%             maxRunTime = structTasksBase(i).runTime;
%         end
%     end
%     %分配deadline
%     for i=1:jobLen
%          structTasksBase(i).deadline = minDeadLine +((structTasksBase(i).runTime - minRunTime)/(maxRunTime-minRunTime))*(maxDeadLine - minDeadLine)+((maxDeadLine - minDeadLine)/100)*rand(1,1);
%     end
    
    disp('虚拟机与任务的初始化数据完成!');
    disp('保存数据中.....');

    save structTasksBase.mat structTasksBase ;
    save ancestorTaskArray.mat ancestorTaskArray ;
    save structLayers.mat structLayers  ;
    save layerMax.mat layerMax;
    taskLen = jobLen;
    save taskLen.mat taskLen;


