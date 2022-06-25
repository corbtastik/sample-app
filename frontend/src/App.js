import logo from './logo.svg';
import './App.css';
import React, {Component} from "react";

class App extends Component {

    constructor(props) {
        super(props);
        this.state = {
            error: null,
            isLoaded: false,
            data: { }
        };
    }

    componentDidMount() {
        fetch(process.env.REACT_APP_API_ENDPOINT + "/data.json")
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({
                        isLoaded: true,
                        data: result
                    });
                },
                (error) => {
                    this.setState({
                        isLoaded: true,
                        error
                    });
                }
            )
    }

    render() {
        const { error, isLoaded, data } = this.state;
        if (error) {
            return <div>Error: {error.message}</div>;
        } else if (!isLoaded) {
            return <div>Loading...</div>;
        } else {
            return (
                <div className="App">
                    <header className="App-header">
                        <img src={logo} className="App-logo" alt="logo"/>
                        <a className="App-link" href="https://reactjs.org" target="_blank" rel="noopener noreferrer">
                            Learn React
                        </a>
                        <code>NODE_ENV={process.env.NODE_ENV}</code>
                        <code>REACT_APP_VERSION={process.env.REACT_APP_VERSION}</code>
                        <code>REACT_APP_API_ENDPOINT={process.env.REACT_APP_API_ENDPOINT}</code>
                        <code>data.api.name={data.api.name}</code>
                        <code>data.api.version={data.api.version}</code>
                        <code>data.api.message={data.api.message}</code>
                    </header>
                </div>
            );
        }
    }
}

export default App;
