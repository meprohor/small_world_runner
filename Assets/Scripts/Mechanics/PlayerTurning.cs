/*
 * PlayerTurning.cs - reads horizontal axis and moves player to appropriate position
 */

/* MonoBehaviour */
using UnityEngine;

public class PlayerTurning : MonoBehaviour
{
	/* maximum angle player can move to */
	public float maxAngle = 15.0f;
	
	/* position and rotation player starts with */
	private Vector3 savedPos,
		savedRot;
	
	void Awake()
	{
		savedPos = transform.localPosition;
		savedRot = transform.localRotation.eulerAngles;
	}
	
	void FixedUpdate()
	{
		/* revert position back to zero */
		transform.localPosition = savedPos;
		transform.localRotation = Quaternion.Euler(savedRot);
		
		/* apply final position/rotation */
		transform.RotateAround(GameManager.instance.world.transform.position, transform.forward, - Input.GetAxis("Horizontal") * maxAngle);
	}
	
	/* gameover */
	void OnTriggerEnter(Collider collider)
	{
		GameManager.instance.GameOver();
	}
}
