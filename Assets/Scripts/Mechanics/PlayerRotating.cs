/*
 * PlayerRotating.cs - rotates playermodel over time
 */
 
using UnityEngine;

public class PlayerRotating : MonoBehaviour
{
	public float anglesPerSecond = 30.0f;
	
	void Update()
	{
		transform.RotateAround(transform.position, Camera.main.transform.right, anglesPerSecond * Time.deltaTime);
	}
}
