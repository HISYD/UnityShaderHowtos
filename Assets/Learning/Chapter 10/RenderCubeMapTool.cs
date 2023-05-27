using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


public class RenderCubemapTool : ScriptableWizard
{
    public Transform RenderFromPosition;
    
    public Cubemap TargetCubemap;

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("Render Agent");
        go.AddComponent<Camera>();
        go.transform.position= RenderFromPosition.transform.position;
        go.GetComponent<Camera>().RenderToCubemap(TargetCubemap);
        
        DestroyImmediate(go);
    }

    private void OnWizardUpdate()
    {
        isValid = (TargetCubemap != null) && (RenderFromPosition != null);
    }

    
    [MenuItem("MyTools/Chapter 10/RenderToCubemap")]
    static void RenderCubeMap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapTool>
            ("Render to the Cubemap", "Render NOW");
    }
}
