package com.yang.crm.workbench.service;

import com.yang.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueService {
    int saveCreateClue(Clue clue);

    List<Clue> queryClueByConditionForPage(Map<String, Object> map);

    int queryCountOfClueByCondition(Map<String, Object> map);

    void deleteClue(String[] clueIds);

    Clue queryClueById(String id);

    int saveEditClue(Clue clue);

    Clue queryClueForDetailById(String id);

    void saveConvertClue(Map<String, Object> map);

    List<String> queryClueStageOfClueGroupByClueStage();

    List<Integer> queryCountOfClueGroupByClueStage();
}
