import React from 'react'
import Link from 'gatsby-link'
import './Header.css'

const Header = ({ siteTitle }) => (
  <div className="Header">
    <div className="HeaderGroup">
      <Link to="/"><img src={require('../images/logo-designcode.svg')} width="30" /></Link>
      <Link to="/courses">Courses</Link>
      <Link to="/courses">Downloads</Link>
      <Link to="/courses">Workshops</Link>
      <Link to="/courses"><button>Buy</button></Link>
    </div>
  </div>
)

export default Header
