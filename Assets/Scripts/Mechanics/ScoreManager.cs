/*
 * ScoreManager.cs - keeps track of user score,
 * data persist upon level reload
 */

 /* MonoBehaviour */
using UnityEngine;
/* Text */
using UnityEngine.UI;

public class ScoreManager : MonoBehaviour
{
	/* reference to UI text that shows timer */
	public Text timer;
	/* time when runner started */
	[HideInInspector]
	public float startTime;
	private float bestTime;
	
	/* deal with internal data */
	void Awake()
	{
		startTime = Time.time;
		DontDestroyOnLoad(gameObject);
	}
	
	/* manage external references */
	void Start()
	{
		DontDestroyOnLoad(timer.transform.parent.gameObject);
	}
	
	/* update timer text */
	void Update()
	{
		float curTime = Time.time - startTime;
		
		if(curTime > bestTime)
			bestTime = curTime;
		
		timer.text = "Score: " + curTime.ToString("#.00") + " (Best: " + bestTime.ToString("#.00") + ")";
	}
}
