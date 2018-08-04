import React from 'react'
import styled from 'styled-components'

const Footer = ({ data }) => (
  <div>
    {data.allContentfulLink.edges.map(edge => (
      <a href={edge.node.url}>{edge.node.title}</a>
    ))}
  </div>
)

// TIME: 1611

export default Footer