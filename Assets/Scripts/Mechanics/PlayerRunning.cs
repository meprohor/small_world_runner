/*
 *
 */

/* MonoBehaviour */
using UnityEngine;

public class PlayerRunning : MonoBehaviour
{
	/* angles player moves per second */
	public float speed;
	
	/* right way for physics */
	void FixedUpdate()
	{
		transform.RotateAround(GameManager.instance.world.transform.position, GameManager.instance.world.transform.right, speed * Mathf.Min(Time.deltaTime, .2f));
	}
}
