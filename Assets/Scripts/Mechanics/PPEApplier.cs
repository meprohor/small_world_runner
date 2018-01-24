/*
 * PPEApplier.cs - applies postprocessing effect
 */

 /* MonoBehaviour */
using UnityEngine;

[ExecuteInEditMode]
public class PPEApplier : MonoBehaviour
{
	/* Material with shader to apply */
	public Material mat;
	
	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		if(null != mat)
			Graphics.Blit(src, dest, mat);
	}
}
