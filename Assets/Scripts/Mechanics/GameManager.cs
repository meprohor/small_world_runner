/*
 * GameManager.cs - spawns enviroment and obstacles,
 * manages biome change processes
 */

/* MonoBehaviour */
using UnityEngine;
/* IEnumerator */
using System.Collections;
/* List */
using System.Collections.Generic;

/*
 * List of Lists of GameObjects
 * easier than editor script
 * 
 * list of prefabs according to biome list
 */
[System.Serializable]
public class PrefabsList
{
	public List<GameObject> prefabs;
}

public class GameManager : MonoBehaviour
{
	/* singleton: easy access from any other class */
	private static GameManager _instance;
	public static GameManager instance
	{
		private set { _instance = value; }
		get { return _instance; }
	}
	
	public ScoreManager scoreManager;
	
	/*
	 * external references to:
	 * world object, that holds sphere collider of a planet
	 * player main object, that spins around world and drags camera behind
	 * enviroment that holds enviromental gameobjects
	 */
	public GameObject world,
		player,
		enviroment;
	
	/* renderer that holds world material (used to change biome) */
	public Renderer worldRenderer;
	private Material worldMaterial
	{
		get{ return worldRenderer.material; }
	}
	
	/* current biome index */
	private int curEnvIndex = 0;
	/* textures list according to biomes */
	public List<Texture2D> envTextures = new List<Texture2D>();
	/* step enviroment changes over second */
	public float envChangeSpeed = .05f;
	
	/* number of enviromental objects spawned per second */
	public float envSpawnRate;
	
	public List<PrefabsList> envPrefabs = new List<PrefabsList>();
	/* angle enviromental objects can spawn at */
	public float minEnvSpawnAngle = 45,
		maxEnvSpawnAngle = 165;
	
	/* gameobjects that can be spawned as obstacles */
	public List<GameObject> obsPrefabs = new List<GameObject>();
	/* angle obstacle objects can spawn at */
	public float obsSpawnAngle = 15.0f,
		obsSpawnRate = 2.0f;
	
	/* time biome stays persistent */
	public float biome_lifeSpan = 20.0f;
	/* time obstacle or enviroment lives in seconds */
	public float env_obsLifespan = 7.5f;
	
	void Awake()
	{
		if(null == instance)
			instance = this;
		else
			Destroy(gameObject);
	}
	
	void Start()
	{
		StartCoroutine("ManageEnviroment");
		StartCoroutine("SpawnEnviroment");
		StartCoroutine("SpawnObstacles");
	}
	
	/* waits for given amount of seconds then chooses other biome and lerps to it */
	private IEnumerator ManageEnviroment()
	{
		int nextEnvIndex;
		float lerpT;
		
		while(true)
		{
			worldMaterial.SetTexture("_MainTex", envTextures[curEnvIndex]);
			lerpT = .0f;
			worldMaterial.SetFloat("_LerpT", lerpT);
			yield return new WaitForSeconds(biome_lifeSpan);
			
			while(curEnvIndex == (nextEnvIndex = Random.Range(0, envTextures.Count))) {}
			
			worldMaterial.SetTexture("_SecondaryTex", envTextures[nextEnvIndex]);
			
			while(lerpT <= 1.0f)
			{
				lerpT += Time.deltaTime * envChangeSpeed;
				worldMaterial.SetFloat("_LerpT", lerpT);
				
				if(curEnvIndex != nextEnvIndex && lerpT > .25f)
					curEnvIndex = nextEnvIndex;
				
				yield return 0;
			}
		}
	}
	
	/* spawns enviromental objects at given rate */
	private IEnumerator SpawnEnviroment()
	{
		while(true)
		{
			float worldRadius = world.GetComponent<SphereCollider>().radius;
			
			yield return new WaitForSeconds(1.0f / envSpawnRate);
			
			float angle = Random.Range(minEnvSpawnAngle, maxEnvSpawnAngle);
			if(Random.value > .5f)
				angle *= -1;
			angle *= Mathf.Deg2Rad;
			
			Vector3 spawnPoint = world.transform.position;
			spawnPoint += - player.transform.up * Mathf.Cos(angle) + player.transform.right * Mathf.Sin(angle);
			
			spawnPoint *= worldRadius * 1.1f;
			
			RaycastHit hit;
			
			if(Physics.Raycast(spawnPoint, -spawnPoint, out hit, worldRadius * .2f))
			{
				GameObject prefab = envPrefabs[curEnvIndex].prefabs[Random.Range(0, envPrefabs[curEnvIndex].prefabs.Count)];
				
				GameObject instantiated = Instantiate(prefab, hit.point, Quaternion.identity, enviroment.transform) as GameObject;
				instantiated.transform.up = hit.normal;
				
				Destroy(instantiated, env_obsLifespan);
			}
		}
	}
	
	
	/* spawns obstacle objects at given rate */
	private IEnumerator SpawnObstacles()
	{
		while(true)
		{
			float worldRadius = world.GetComponent<SphereCollider>().radius;
			
			yield return new WaitForSeconds(1.0f / obsSpawnRate);
			
			float angle = Random.Range(- obsSpawnAngle, obsSpawnAngle);
			angle *= Mathf.Deg2Rad;
			
			Vector3 spawnPoint = world.transform.position;
			spawnPoint += - player.transform.up * Mathf.Cos(angle) + player.transform.right * Mathf.Sin(angle);
			
			spawnPoint *= worldRadius * 1.1f;
			
			RaycastHit hit;
			
			if(Physics.Raycast(spawnPoint, -spawnPoint, out hit, worldRadius * .2f))
			{
				GameObject prefab = obsPrefabs[Random.Range(0, obsPrefabs.Count)];
				
				GameObject instantiated = Instantiate(prefab, hit.point, Quaternion.identity, enviroment.transform) as GameObject;
				instantiated.transform.up = hit.normal;
				
				Destroy(instantiated, env_obsLifespan);
			}
		}
	}
	
	public void GameOver()
	{
		scoreManager.startTime = Time.time;
	}
}
