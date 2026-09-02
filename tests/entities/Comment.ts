import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToOne, JoinColumn } from 'typeorm'
import { Post } from './Post'
import { User } from './User'

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn()
  id: number

  @Column()
  content: string

  @ManyToOne(() => User)
  user: User

  @OneToOne(() => Post)
  @JoinColumn()
  post: Post
}