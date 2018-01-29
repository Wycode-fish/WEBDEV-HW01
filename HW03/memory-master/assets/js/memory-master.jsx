import React from 'react';
import ReactDom from 'react-dom';
import { Button } from 'reactstrap';

export default function init (root) {
	ReactDom.render (<MemoryMaster />, root);
}

/*
	memory-master states:
	{
		tiles: [List of Tile],
		click: Int
	}

	A Tile item is:
	{ letter: String, selected: Bool, matched: Bool, id: Int}
*/

class MemoryMaster extends React.Component {
	constructor (props) {
		super (props);
		let randomizedLetters = this.randomizedLetters("ABCDEFGH");
		let id = 0;
		let tiles = _.map(randomizedLetters, (l)=>{
			return {letter:l, selected:false, matched:false, id:id++};
		});
		this.state = {
			tiles: tiles,
			click: 0,
		};
	}

	reconstructor () {
		let randomizedLetters = this.randomizedLetters("ABCDEFGH");
		let id=0;
		let tiles = _.map(randomizedLetters, (l)=>{
			return {letter:l, selected:false, matched:false, id:id++};
		});
		let newState = _.extend(this.state, {
			tiles:tiles,
			click:0,
		});
		this.setState(newState);
	}

	randomizedLetters (str) {
		return _.shuffle ((str+str).split(""));
	}

	tiles () {
		return this.state.tiles;
	}

	letters () {
		let ll = _.map (this.tiles(), (t)=>{
			return t.letter;
		});
		return _.uniq(ll);
	}

	selected () {
		return this.state.selected;
	}

	matchedLetters () {
		let ml = [];
		this.tiles().forEach ((t)=>{
			if (t.matched) ml.push(t.letter);
		});
		return _.uniq(ml);
	}

	clickNum () {
		return this.state.click;
	}

	someSelected () {
		let someSelected = 0;
		this.tiles().forEach( (t) => {
			if (t.selected) someSelected+=1;
		});
		return someSelected;
	}

	selectedLetters () {
		let selectedLetters = [];
		this.tiles().forEach ( (t)=>{
			if (t.selected) selectedLetters.push(t.letter);
		});
		return selectedLetters;
	}

	flipTile (id) {
		let tl = _.map (this.tiles(), (t)=>{
			if(t.id==id) 
				return _.extend(t, {
					selected:true,
				});
			else return t;
			});
		let st1 = _.extend(this.state, {
			tiles:tl,
			click:this.clickNum()+1,
		});
		this.setState(st1);
	}

	setClick (id) {
		// no matter what, set the tile selected
		let currSelected = this.selectedLetters();
		if (currSelected.length<2){
			this.flipTile(id);
		}
		
		// determine behaviors.
		let selecteds = this.selectedLetters();
		console.log(selecteds.length);
		if (selecteds.length==2){
			if (selecteds[0]==selecteds[1]){
				let lmatch = _.map(this.tiles(), (t) => {
					if (t.letter==selecteds[0]){
						return _.extend(t, {
							selected:false,
							matched:true,
						});
					}
					else return t;
				});
				let st2 = _.extend(this.state, {
					tiles:lmatch,
				})
				this.setState(st2);
				this.winGame();
			}
			else {
				let that = this;
				setTimeout(function(){
					that.deselectAll();
				},1000);
				
			}
		}
		
	}

	deselectAll () {
		let deselected = _.map(this.tiles(), (t)=>{
			return _.extend(t, {
				selected:false
			});
		});
		let st = _.extend(this.state, {
			tiles: deselected,
		});
		this.setState(st);
	}

	winGame () {
		let finish = this.allMatch();
		if (finish) {
			let score = this.score();
			if (confirm("score:  "+Math.round(score)+"/100. Press Enter to restart.")){
				this.reconstructor();
			}
		}
	}

	allMatch () {
		let finish = true;
		this.tiles().forEach((t)=>{
			finish = finish && t.matched;
		});
		return finish;
	}

	score () {
		let score = 100;
		let cl = this.clickNum();
		let matchedNum = this.matchedLetters().length;
		if (cl > this.letters().length*2) 
			score*=(2*matchedNum/cl);
		return score;
	}

	render () {
		let tileList = _.map (this.tiles(), (t, ii)=>{
			console.log("tile: "+t.letter);
			return <Tile tile={t} clickTile={this.setClick.bind(this)} key={ii}/>;
		});
		console.log("---");
		return (
			<div>
				<ul>
					{tileList.slice(0, 4)}
				</ul>
				<ul>
					{tileList.slice(4, 8)}
				</ul>
				<ul>
					{tileList.slice(8, 12)}
				</ul>
				<ul>
					{tileList.slice(12, 16)}
				</ul>
				<InfoBar root={this}/>
				<RestartBtn root={this} restart={this.reconstructor.bind(this)}/>
			</div>
		);
	}
}

function InfoBar (props) {
	let cl = props.root.clickNum();
	let matchedNum = props.root.matchedLetters().length;
	return <span>
		<span className="click">Clicks: {cl} </span>
		<span className="match">Match: {matchedNum}</span>
	</span>;
}

function RestartBtn (props) {
	return <span className="restart">
	<Button onClick={()=>props.restart()}>Restart</Button>
	</span>
}

function Tile (props) {
	let show = false;
	let tile = props.tile;
	if (tile.matched || tile.selected) {
		show=true;
	}
	if (show) return <li><button className="selected">{tile.letter}</button></li>;
	else return <li><Button className="unselected" onClick={()=>props.clickTile(tile.id)}></Button></li>;
}



